@x
if (strcmp(time, "21:00:00") >= 0 || strcmp(time, "06:00:00") < 0) display_write4(0x0A, 0x01);
@y
if (strcmp(time, "21:00:00") >= 0 || strcmp(time, "05:00:00") < 0) display_write4(0x0C, 0x00);
@z

@x
if (strcmp(time, "06:00:00") >= 0 && strcmp(time, "21:00:00") < 0) display_write4(0x0A, 0x0F);
@y
if (strcmp(time, "05:00:00") >= 0 && strcmp(time, "21:00:00") < 0) display_write4(0x0C, 0x01);
@z
