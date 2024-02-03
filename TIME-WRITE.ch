@x
  if (argc == 1) return 2;
@y
  if (argc < 3) return 2;
@z

@x
args[1] = atoi(argv[1]);
if (argc == 3) args[7] = 'B';
@y
if (*argv[1] != '-') args[1] = atoi(argv[1]);
if (argc == 4) args[7] = 'B';
if (*argv[1] != '-') args[2] = 1; // show
if (*argv[2] != '-') args[3] = 1; // seconds
@z
