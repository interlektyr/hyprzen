#!/bin/bash

# Sökvägar
WALLPAPER_DIR="$HOME/.config/quickshell/assets/wallpapers"
JSON_FILE="$HOME/.config/quickshell/scripts/zen_settings.json"

# Kontrollera att jq finns installerat
if ! command -v jq &>/dev/null; then
  echo "Fel: 'jq' är inte installerat. Installera det för att fortsätta."
  exit 1
fi

# Kontrollera att mappen finns
if [ ! -d "$WALLPAPER_DIR" ]; then
  echo "Fel: Mappen $WALLPAPER_DIR hittades inte."
  exit 1
fi

# Hämta 10 slumpmässiga unika bilder med fullständig sökväg (stöder vanligaste bildformaten)
mapfile -t images < <(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) | shuf -n 10)

# Kontrollera om det finns tillräckligt många bilder
if [ "${#images[@]}" -lt 10 ]; then
  echo "Fel: Det finns färre än 10 bilder i mappen (${#images[@]} st hittades)."
  exit 1
fi

# Uppdatera JSON-filen med jq genom att skicka med bilderna som variabler
jq --arg p1 "${images[0]}" \
  --arg p2 "${images[1]}" \
  --arg p3 "${images[2]}" \
  --arg p4 "${images[3]}" \
  --arg p5 "${images[4]}" \
  --arg p6 "${images[5]}" \
  --arg p7 "${images[6]}" \
  --arg p8 "${images[7]}" \
  --arg p9 "${images[8]}" \
  --arg p10 "${images[9]}" \
  '.dw["1"] = $p1 | .dw["2"] = $p2 | .dw["3"] = $p3 | .dw["4"] = $p4 | .dw["5"] = $p5 | .dw["6"] = $p6 | .dw["7"] = $p7 | .dw["8"] = $p8 | .dw["9"] = $p9 | .dw["10"] = $p10' \
  "$JSON_FILE" >"${JSON_FILE}.tmp" && mv "${JSON_FILE}.tmp" "$JSON_FILE"

echo "Klart! zen_settings.json har uppdaterats med 10 nya slumpmässiga bakgrunder."
