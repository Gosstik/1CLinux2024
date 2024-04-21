# System calls

Шпаргалка по сисколам: https://www.kernel.org/doc/html/v6.7/process/adding-syscalls.html

Ссылка на нужный раздел: https://www.kernel.org/doc/html/v6.7/process/adding-syscalls.html#generic-system-call-implementation

Более сжатая и простая инструкция на примере `task1` модуля `phone_book.ko`:
1) Копируем папку `phone_book_module` в папку `linux-6.7.4/`
   ```bash
   # from kernel folder
   cp -r ./phone_book_module ./linux-6.7.4
   ```
2) Изменяем `linux-6.7.4/Makefile`. Ищем `core-y :=` и дописываем:
   ```makefile
   core-y := phone_book_module/
   ```
   **Обязательно нужно добавить / в конце**.

3) Находим файл `syscall_64.tbl`
   ```bash
   cd linux-6.7.4
   find ./ -name syscall_64.tbl
   gedit ./arch/x86/entry/syscalls/syscall_64.tbl
   ```
4) Добавляем свой сисколы перед комментарием `Due to a historical design error ...`. **Должно быть по одному табу между первыми колонками, и 2 таба между последними. Пробелы не распарсятся**
   ```text
   457	common	get_pb_user		sys_get_pb_user
   458	common	add_pb_user		sys_add_pb_user
   459	common	del_pb_user		sys_del_pb_user
   ```

5) Открываем файл
    ```bash
    gedit kernel/linux-6.7.4/include/linux/syscalls.h
    ```

6) В самом низу файла перед `#endif` нужно добавить строки
   ```c
   struct user_data_t;
   asmlinkage long sys_get_pb_user(
   const char __user* surname,
   struct user_data_t __user* output_data
   );
   asmlinkage long sys_add_pb_user(struct user_data_t __user* input_data);
   asmlinkage long sys_del_pb_user(const char __user* surname);
   ```
   
7) Пересобираем ядро (`make -j9 all`, ...)

