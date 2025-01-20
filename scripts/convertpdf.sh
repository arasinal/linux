#!/bin/bash

# Alias olarak kullanmak için /home içinde scripts klasörüne ekle. "my_aliases" klasöründeki "myaliases" dosyasına kullanmak istediğin alisları ekle. Ardından "source ~/.bashrc" koduyla aktive et. 
# Kullanım kontrolü
if [ "$#" -ne 1 ]; then
    echo "Kullanım: $0 <dosya_adi.md>"
    exit 1
fi

# Aranacak ana dizinler
search_dirs=(
    "$HOME/Documents"
    "$HOME/Downloads"
)

# Girdi dosyasını arama
input_file=""
for dir in "${search_dirs[@]}"; do
    # Alt dizinlerle birlikte dosyayı ara
    found_file=$(find "$dir" -type f -name "$1" 2>/dev/null)
    if [ -n "$found_file" ]; then
        input_file="$found_file"
        break
    fi
done

# Dosya bulunamadıysa hata mesajı
if [ -z "$input_file" ]; then
    echo "Hata: Dosya belirtilen dizinlerde bulunamadı: $1"
    exit 1
fi

# Dosya uzantısını kontrol et
if [[ "$input_file" != *.md ]]; then
    echo "Hata: Girdi dosyası bir Markdown dosyası olmalıdır (.md uzantılı)."
    exit 1
fi

# Çıktı dosyasını oluştur
output_file="${input_file%.md}.pdf"

# Dönüştürme işlemi
if pandoc "$input_file" -o "$output_file" --pdf-engine=weasyprint; then
    echo "Dönüştürme tamamlandı: $output_file"
else
    echo "Hata: Dönüştürme başarısız oldu."
    exit 1
fi

