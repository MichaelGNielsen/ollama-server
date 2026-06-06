#!/bin/bash

# systemctl status ollama.service 
# ● ollama.service - Ollama Service
#      Loaded: loaded (/etc/systemd/system/ollama.service; enabled; preset: enabled)
#      Active: active (running) since Sat 2026-06-06 07:22:18 CEST; 14min ago
#    Main PID: 2401 (ollama)
#       Tasks: 14 (limit: 153548)
#      Memory: 354.6M (peak: 536.6M)
#         CPU: 4.374s
#      CGroup: /system.slice/ollama.service
#              └─2401 /usr/local/bin/ollama serve
#
# Jun 06 07:22:18 nuc5 ollama[2401]: time=2026-06-06T07:22:18.430+02:00 level=INFO source=routes.go:1981 msg="Listening on 127.0.0.1:11434 (version 0.30.5)"
# Jun 06 07:22:18 nuc5 ollama[2401]: time=2026-06-06T07:22:18.432+02:00 level=INFO source=model_list_cache.go:111 msg="model list cache hydration complete" models=0 failures=0 elapsed=1.81576ms
# Jun 06 07:22:18 nuc5 ollama[2401]: time=2026-06-06T07:22:18.432+02:00 level=INFO source=runner.go:60 msg="discovering available GPUs..."
# Jun 06 07:22:18 nuc5 ollama[2401]: time=2026-06-06T07:22:18.433+02:00 level=WARN source=model_recommendations.go:168 msg="model recommendations refresh failed" error="Get \"https://ollama.com/api/experimental/model-recommendations\": dial tcp: lookup ollama.com on 127.0.0.53:53>
# Jun 06 07:22:18 nuc5 ollama[2401]: time=2026-06-06T07:22:18.433+02:00 level=INFO source=model_recommendations.go:177 msg="model recommendations cache sleep scheduled" wait=5m20.609363893s consecutive_failures=1
# Jun 06 07:22:18 nuc5 ollama[2401]: time=2026-06-06T07:22:18.434+02:00 level=WARN source=model_show_cache.go:142 msg="model show cloud cache hydration failed" error="Get \"https://ollama.com:443/api/tags?ts=1780723338\": dial tcp: lookup ollama.com on 127.0.0.53:53: server misbe>
# Jun 06 07:22:21 nuc5 ollama[2401]: time=2026-06-06T07:22:21.387+02:00 level=INFO source=llama_server.go:292 msg="skipping CUDA device — compute capability not in compiled architectures" device="NVIDIA GB10" cc=1210 archs="[500 520 600 610 700 750 800 860 890 900 1200]" libDirs=>
# Jun 06 07:22:24 nuc5 ollama[2401]: time=2026-06-06T07:22:24.799+02:00 level=INFO source=types.go:32 msg="inference compute" id=0 filter_id=0 library=CUDA compute=12.1 name=CUDA0 description="NVIDIA GB10" libdirs=ollama,cuda_v13 driver=13.0 pci_id=000f:01:00.0 type=iGPU total="1>
# Jun 06 07:22:24 nuc5 ollama[2401]: time=2026-06-06T07:22:24.799+02:00 level=INFO source=routes.go:2031 msg="vram-based default context" total_vram="121.6 GiB" default_num_ctx=262144
# Jun 06 07:27:39 nuc5 ollama[2401]: time=2026-06-06T07:27:39.295+02:00 level=INFO source=model_recommendations.go:177 msg="model recommendations cache sleep scheduled" wait=4h39m45.338926006s consecutive_failures=0


sudo systemctl stop ollama
sudo systemctl disable ollama