export default function(name) {
  const extension = name.split('.')[name.split('.').length - 1];
  switch (extension) {
    case "pdf": {
      return "fa-file-pdf-o";
    }
    case "bmp":
    case "jpeg":
    case "jpg":
    case "png":
    case "svg": {
      return "fa-file-image-o";
    }
    case "xls":
    case "xlsx":
    case "csv": {
      return "fa-file-excel-o";
    }
    case "doc":
    case "docx": {
      return "fa-file-word-o";
    }
    case "ppt":
    case "pptx": {
      return "fa-file-powerpoint-o";
    }
    case "mp4":
    case "mpeg":
    case "wmv": {
      return "fa-file-video-o";
    }
    case "mp3":
    case "ogg":
    case "wma": {
      return "fa-file-audio-o";
    }
    case "zip":
    case "tar": {
      return "fa-file-archive-o";
    }
    case "txt": {
      return "fa-file-text-o";
    }
    default: {
      return "fa-file-o";
    }
  }
};
