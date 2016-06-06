# sddm-themes
[sddm](https://github.com/sddm/sddm) themes for playing video and audio files who based on maui theme.

The themes are configurable. It's means you can change the theme without touching qml files. Only modify the **theme.conf** file.

## my current environment
- Qt 5.5.1
- sddm 0.13.0

## I've wrote two themes.

1. amaui

   **still image** background and optionally playing audio files

2. vmaui

   **video** background and optionally playing audio files

## Instalation

Copy vmaui or amaui directory to ThemeDir.

Default ThemeDir value is "/usr/share/sddm/themes".

You can specify the directory by /etc/sddm.conf

## How to setup

**At least, you have to change the `background` or `video_files` value by your file name.**

Modify your theme.conf in vmaui/amaui directory.
```
text_color=black
clock_color=black
clock_font=Oxygen
```

### for amaui
```
background=resources/sky.jpg,/usr/share/image/sea.jpg
#audio_files=
```

### for vmaui 

```
video_files=resources/sky.mp4,/usr/share/video/sea.mp4
#audio_files=
```

`background`, `video_files` and `audio_files` can specify multiple files by separated by `,' (commas).

If multiple files are specified, then randomly used.

file path can use absolute path and relative path from **theme.conf** file.

#### in vmaui
If `audio_files` specified, playing the files. otherwise, playing the video sound. 
