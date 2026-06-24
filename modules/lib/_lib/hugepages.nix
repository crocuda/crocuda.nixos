{lib, ...}: let
  # Power base 10
  _pow = n: i:
    if i == 1
    then n
    else if i == 0
    then 1
    else n * _pow n (i - 1);

  # Set dedicated RAM in GB (ex: 16),
  # and hugepage size in kb (default 2048)
  ram_to_hugepage = dedicated_ram: hugepage_size: toString ((dedicated_ram * _pow 1024 2) / hugepage_size);
in {
  inherit ram_to_hugepage;
}
