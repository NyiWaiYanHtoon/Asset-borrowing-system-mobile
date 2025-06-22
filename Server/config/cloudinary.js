const cloudinary = require('cloudinary').v2;
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const multer = require('multer');
cloudinary.config({
    cloud_name: 'dxwpkqlb0',
    api_key: '472299798268547',
    api_secret: '_AQ0stuX4fGvi3IIBg-pZgHPNBU'
});
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'temp/'); 
    },
    filename: (req, file, cb) => {
        cb(null, `${Date.now()}-${file.originalname}`);
    },
});
const upload = multer({ storage });

module.exports= {
    upload,
    cloudinary
}