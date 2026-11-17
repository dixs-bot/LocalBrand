export function whatsappUrl(message: string) {
  const phone = process.env.NEXT_PUBLIC_WHATSAPP_NUMBER || "";
  return `https://wa.me/${phone.replace(/\D/g, "")}?text=${encodeURIComponent(message)}`;
}
