#!/bin/bash
# =============================================
# GPU Detection Script til Asus Ascent GX10 (GB10)
# Unified Memory support (128 GB shared)
# =============================================

echo "=== GPU Detection - Asus Ascent GX10 (GB10) ==="

# 1. Generel PCI check
echo "PCI Devices:"
lspci | grep -E "VGA|3D|Display" || echo "Ingen GPU fundet"

echo -e "\nNVIDIA specifik check:"
if command -v nvidia-smi &> /dev/null; then
    echo "✅ nvidia-smi fundet"
    
    GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null)
    echo "GPU: $GPU_NAME"
    
    # Forsøg GPU memory (virker ikke på GB10 unified)
    TOTAL_MEM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null)
    
    if [[ "$TOTAL_MEM" == "[N/A]" ]] || [ -z "$TOTAL_MEM" ]; then
        echo "ℹ️  Unified Memory arkitektur detekteret (ingen separat GPU VRAM)"
        echo "   Bruger systemets samlede RAM som GPU-hukommelse"
    else
        echo "Total GPU memory: ${TOTAL_MEM} MiB"
    fi
    
    # Tjek systemets frie RAM (det er det der tæller på GB10)
    echo -e "\n=== System Memory (Unified 128 GB) ==="
    free -h | grep -E "Mem:|total"
    
    # Simpel check: Er der mere end 32 GB fri?
    FREE_GB=$(free -g | awk '/^Mem:/ {print $4}')
    
    if [ "$FREE_GB" -gt 32 ]; then
        echo "✅ Mere end 32 GB fri hukommelse (${FREE_GB} GB) — Godt til store modeller!"
    else
        echo "⚠️  Under 32 GB fri hukommelse (${FREE_GB} GB)"
    fi
    
    echo "✅ NVIDIA GPU er aktiv"
else
    echo "❌ nvidia-smi ikke fundet"
fi

echo -e "\nDetaljeret GPU info:"
lspci -nnk | grep -A3 -E "VGA|3D|Display"
