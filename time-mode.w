if (argc != 2) return 1;
if (strcmp(argv[1], "off") == 0) cfsetspeed B1200 /dev/ttyACM0
if (strcmp(argv[1], "night") == 0) cfsetspeed B2400 /dev/ttyACM0
if (strcmp(argv[1], "day") == 0) cfsetspeed B4800 /dev/ttyACM0
