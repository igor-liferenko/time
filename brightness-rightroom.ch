@x
if (strcmp(time, "06:00:00") >= 0 && strcmp(time, "21:00:00") < 0) display_write4(0x0A, 0x0F);
@y
if (strcmp(time, "06:00:00") >= 0 && strcmp(time, "21:00:00") < 0) display_write4(0x0A, 0x0F);
if (strcmp(time, "00:00:00") = 0) display_write4(0x0C, 0x00);
if (strcmp(time, "04:00:00") != 0) display_write4(0x0C, 0x01);
@z
