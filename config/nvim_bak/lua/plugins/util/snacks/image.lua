return {
  doc = {
    float = false,
    inline = true,
    max_width = 50,
    max_height = 30,
    wo = {
      wrap = true,
    },
  },
  convert = {
    notify = true,
    command = "magick",
  },
  img_dirs = {
    "img",
    "images",
    "assets",
    "static",
    "public",
    "media",
    "attachments",
    "~/Library",
    "~/Desktop",
    "~/Downloads",
  },
}
