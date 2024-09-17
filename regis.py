import logging
import subprocess
import requests
from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import Updater, CommandHandler, CallbackContext, ConversationHandler, MessageHandler, Filters, CallbackQueryHandler

# Konfigurasi logging
logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s', level=logging.INFO)
logger = logging.getLogger(__name__)

# Load admin IDs from file
def load_admin_ids(file_path):
    try:
        with open(file_path, 'r') as file:
            admin_ids = [int(line.strip()) for line in file if line.strip().isdigit()]
        return admin_ids
    except Exception as e:
        logger.error(f"Error loading admin IDs: {e}")
        return []

# Daftar ID admin yang diizinkan
ADMIN_IDS = load_admin_ids('wendy.txt')

# States for conversation
REGISTER, REGISTER_NAME, REGISTER_EXP, EXTEND, EXTEND_DAYS, DELETE = range(6)

def count_registered_ips():
    try:
        response = requests.get('https://raw.githubusercontent.com/bowowiwendi/ipvps/main/ip')
        response.raise_for_status()
        ip_list = response.text.splitlines()
        return len(ip_list)
    except requests.RequestException as e:
        logger.error(f"Error while fetching IP list: {e}")
        return 0

# Fungsi untuk menampilkan menu awal dengan tombol
def regis(update: Update, context: CallbackContext) -> int:
    user = update.message.from_user
    user_id = user.id
    username = user.username if user.username else "Tidak ada username"

    total_ips = count_registered_ips()

    keyboard = [
        [InlineKeyboardButton("🆕 Daftarkan IP", callback_data='register')],
        [InlineKeyboardButton("🔄 Perpanjang IP", callback_data='extend')],
        [InlineKeyboardButton("❌ Hapus IP", callback_data='delete')]
    ]
    reply_markup = InlineKeyboardMarkup(keyboard)
    update.message.reply_text(
        f"Selamat datang, {username} (ID: {user_id})! 🎉\n\n"
        f"Total IP terdaftar: {total_ips}\n\n"
        "Gunakan tombol di bawah untuk mengelola IP:\n"
        "🔹 Daftarkan IP baru\n"
        "🔹 Perpanjang masa berlaku IP\n"
        "🔹 Hapus IP yang terdaftar\n",
        reply_markup=reply_markup
    )
    return ConversationHandler.END

def button(update: Update, context: CallbackContext) -> int:
    query = update.callback_query
    query.answer()

    if query.data == 'register':
        query.edit_message_text("🔄 Masukkan IP yang ingin didaftarkan:")
        return REGISTER
    elif query.data == 'extend':
        query.edit_message_text("🔄 Masukkan IP yang ingin diperpanjang:")
        return EXTEND
    elif query.data == 'delete':
        query.edit_message_text("❌ Masukkan IP yang ingin dihapus:")
        return DELETE

def register_ip(update: Update, context: CallbackContext) -> int:
    user_id = update.message.from_user.id
    if user_id not in ADMIN_IDS:
        update.message.reply_text("🚫 Anda tidak memiliki izin untuk menggunakan perintah ini.")
        return ConversationHandler.END

    context.user_data['ip'] = update.message.text
    update.message.reply_text("✍️ Masukkan Nama:")
    return REGISTER_NAME

def handle_register_name(update: Update, context: CallbackContext) -> int:
    context.user_data['name'] = update.message.text
    update.message.reply_text("📅 Masukkan Masa Berlaku (hari):")
    return REGISTER_EXP

def finalize_register(update: Update, context: CallbackContext) -> int:
    exp = update.message.text
    ip = context.user_data['ip']
    name = context.user_data['name']

    try:
        result = subprocess.run(
            ["/bin/bash", "add-vps.sh", ip, name, exp],
            capture_output=True,
            text=True
        )
        if result.returncode == 0:
            update.message.reply_text(f"✅ IP berhasil didaftarkan!\nOutput:\n{result.stdout}")
        else:
            update.message.reply_text(f"❌ Error:\n{result.stderr}")
    except Exception as e:
        logger.error(f"Error while registering IP: {e}")
        update.message.reply_text(f"🚨 Terjadi kesalahan: {e}")

    return ConversationHandler.END

def handle_extend_ip(update: Update, context: CallbackContext) -> int:
    context.user_data['ip'] = update.message.text
    update.message.reply_text("📅 Masukkan Tambahan Hari:")
    return EXTEND_DAYS

def finalize_extend(update: Update, context: CallbackContext) -> int:
    extra_days = update.message.text
    ip = context.user_data['ip']

    try:
        result = subprocess.run(
            ["/bin/bash", "renew-ip.sh", ip, extra_days],
            capture_output=True,
            text=True
        )
        if result.returncode == 0:
            update.message.reply_text(f"✅ Masa berlaku IP berhasil diperpanjang!\nOutput:\n{result.stdout}")
        else:
            update.message.reply_text(f"❌ Error:\n{result.stderr}")
    except Exception as e:
        logger.error(f"Error while extending IP: {e}")
        update.message.reply_text(f"🚨 Terjadi kesalahan: {e}")

    return ConversationHandler.END

def handle_delete_ip(update: Update, context: CallbackContext) -> int:
    ip = update.message.text

    try:
        result = subprocess.run(
            ["/bin/bash", "del-ip.sh", ip],
            capture_output=True,
            text=True
        )
        if result.returncode == 0:
            update.message.reply_text(f"✅ IP berhasil dihapus!\nOutput:\n{result.stdout}")
        else:
            update.message.reply_text(f"❌ Error:\n{result.stderr}")
    except Exception as e:
        logger.error(f"Error while deleting IP: {e}")
        update.message.reply_text(f"🚨 Terjadi kesalahan: {e}")

    return ConversationHandler.END

def main() -> None:
    TOKEN = "7187512652:AAHIeQYsIAECwaeqkTD80xJpqCS8PA55qcI"

    updater = Updater(TOKEN)
    dispatcher = updater.dispatcher

    conversation_handler = ConversationHandler(
        entry_points=[CallbackQueryHandler(button)],
        states={
            REGISTER: [MessageHandler(Filters.text & ~Filters.command, register_ip)],
            REGISTER_NAME: [MessageHandler(Filters.text & ~Filters.command, handle_register_name)],
            REGISTER_EXP: [MessageHandler(Filters.text & ~Filters.command, finalize_register)],
            EXTEND: [MessageHandler(Filters.text & ~Filters.command, handle_extend_ip)],
            EXTEND_DAYS: [MessageHandler(Filters.text & ~Filters.command, finalize_extend)],
            DELETE: [MessageHandler(Filters.text & ~Filters.command, handle_delete_ip)],
        },
        fallbacks=[]
    )

    dispatcher.add_handler(CommandHandler("regis", regis))
    dispatcher.add_handler(conversation_handler)

    updater.start_polling()
    updater.idle()

if __name__ == '__main__':
    main()
