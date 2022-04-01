// Cut out a rectangular region of an image, and save this region as a new (rgb) image.
// Parameters: Source file, left, top, width, height, destination file.
//                          ( the rectangular region )
// In Powershell: node extractRegion test_graphics/arthur_right.png 0 0 16 16 myslice.png
const sharp = require("sharp");

async function extractRegion() {
  sharp(process.argv[2])
    .extract({ left: parseInt(process.argv[3]), top: parseInt(process.argv[4]), width: parseInt(process.argv[5]), height: parseInt(process.argv[6]) })
    .toFormat ('png')
    .toFile(process.argv[7], function(err) {
  });
};
extractRegion();