# Low-pass фильтр на CdM16
## Структура
### Железо
- [vivado_res](vivado_res) - Исходники, из которых можно собрать проект Vivado
    - [top.sv](vivado_res/top.sv) -  Обвязка процессора, работа с ADC/DAC
- [Исходники процессора CdM16](/make_shit/verilog) - главный модуль в CdM16.sv
    - Для работы нужно сгенерировать verilog из [микрокода](/make_shit/ucode) скриптом [gen_ucode.py](../gen_ucode.py)
- [Описание архитектуры CdM16](https://github.com/cdm-processors/cdm-devkit/blob/master/docs/cdm16/cdm16-overview.md) - не моё

### Софт
- [Ассемблер CdM16](https://pypi.org/project/cdm-devkit/) - не мой
- [Компилятор Си](https://github.com/leadpogrommer/llvm-project-cdm)
- [cdm_spi](cdm_spi) - программатор
- Исходники фильтра - main.c, font.h, start.asm

В [build](build) лежит скомпилированный main.c (main.asm) и собранная прошивка (audio.img)