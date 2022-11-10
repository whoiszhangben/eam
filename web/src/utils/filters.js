export const filters = {
    fileSize: (value) => {
      if (value < 1024 * 1024) {
        return (Math.round((value * 100) / 1024) / 100).toString() + 'KB';
      } else {
        return (
          (Math.round((value * 100) / (1024 * 1024)) / 100).toString() + 'MB'
        );
      }
    },
  };
  