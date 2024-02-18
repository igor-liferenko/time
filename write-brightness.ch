@x
  @<Open serial port@>@;
@y
  @<Open serial port@>@;
  char args[8] = {'A'};
  if (argc == 1) 
    args[1] = 15, args[2] = 1; /* without arguments - full brightness */
  else
    if (*argv[1] != '-') args[1] = atoi(argv[1]), args[2] = 1;
  if (write(fd, args, 8) == -1)
    return 1;
@z
