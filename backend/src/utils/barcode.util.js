// backend/src/utils/barcode.util.js
const bwipjs = require("bwip-js");
const path = require("path");
const fs = require("fs");
require("dotenv").config();

const OUT_DIR =
  process.env.BARCODE_OUTPUT_DIR || path.join(__dirname, "../../docs/barcodes");

async function generateBarcodeImage(barcodeString, opts = {}) {
  try {
    // ensure folder exists
    fs.mkdirSync(OUT_DIR, { recursive: true });

    const filename = `${barcodeString}.png`;
    const filePath = path.join(OUT_DIR, filename);

    // bwip-js options for Code128
    const bwipOpts = {
      bcid: "code128",
      text: String(barcodeString),
      scale: opts.scale || 3,
      height: opts.height || 10,
      includetext: opts.includetext !== undefined ? opts.includetext : true,
      textxalign: opts.textxalign || "center",
      textsize: opts.textsize || 10,
    };

    // generate buffer
    const pngBuffer = await new Promise((resolve, reject) => {
      bwipjs.toBuffer(bwipOpts, function (err, png) {
        if (err) return reject(err);
        resolve(png);
      });
    });

    // write file
    fs.writeFileSync(filePath, pngBuffer);

    // return relative path (from project root) so frontend can use it if needed
    return filePath;
  } catch (err) {
    console.error("generateBarcodeImage error", err);
    throw err;
  }
}

module.exports = {
  generateBarcodeImage,
};
