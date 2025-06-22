const express = require('express');
const app = express();
const {
    register,
    login,
    authenticateToken
} = require('./lib/auth.js');
const {
    editProfile,
    editAsset,
    returnItem,
    takeoutItem,
    cancelItem,
    approveItem,
    rejectItem
} = require('./lib/edit.js');
const {
    addAsset,
    borrowItem
} = require('./lib/add.js');
const {
    getStudentHistory,
    getLecturerHistory,
    getStaffHistory,
    getRequestStudent,
    getRequestLecturer,
    getManageStaff,
    dashboard,
    getProfilePhotoUrl,
    getAssetPhotoUrl
} = require('./lib/get.js');
const {
    upload,
    cloudinary
} = require('./config/cloudinary.js');
const con = require('./config/db.js');
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
require('dotenv').config()
const { v4: uuidv4 } = require('uuid');
const fs = require('fs');
const {
    sendOTP,
    verifyOTP
} = require('./lib/otp.js');
const job =  require('./lib/schedules.js');

app.post('/sendOTP', (req, res) => {
    const email= req.body.email;
    sendOTP({
        email: email,
        subject: 'OTP Verification',
    }, res);
})
app.post('/verifyOTP', (req, res) =>{
    const {hash, expires, email, otp }= req.body;
    verifyOTP({
        hash,
        expires,
        email,
        otp
    }, res);
})
app.post('/register', (req, res) => {
    const { email, psw} = req.body;
    console.log(email);
    console.log(psw);
    register(email, psw, res);
})
app.post('/login', (req, res) => {
    const { email, psw } = req.body;
    login(email, psw, res);
})
app.post('/editProfile', upload.single('photo'), authenticateToken, async (req, res) => {
    const { newName, newEmail, newId, isRemoved } = req.body;
    const user = req.user;
    let oldphotoUrl = await getProfilePhotoUrl(user.uid);
    let photoUrl = oldphotoUrl;
    if (req.file) {
        try {
            if (oldphotoUrl) {
                let public_id_ary = oldphotoUrl.split('/').pop().split('.');
                public_id_ary.pop();
                const public_id = public_id_ary.join(".");
                await cloudinary.uploader.destroy(public_id);
            }
            const result = await cloudinary.uploader.upload(req.file.path,
                {
                    public_id: `${uuidv4()}-${req.file.originalname}`
                }
            );
            photoUrl = result.secure_url;
            fs.unlink(req.file.path, (err) => {
                if (err) console.error("Error deleting temporary file:", err);
            });
        } catch (error) {
            console.log(error);
            return res.status(500).send("Error uploading to Cloudinary");
        }
    } else if (isRemoved) {
        if (oldphotoUrl) {
            let public_id_ary = oldphotoUrl.split('/').pop().split('.');
            public_id_ary.pop();
            const public_id = public_id_ary.join(".");
            await cloudinary.uploader.destroy(public_id);
        }
        photoUrl = null;
    }
    editProfile(user.uid, newName, newEmail, newId, photoUrl, res);
})
app.post('/editAsset', upload.single('photo'), async (req, res) => {
    const { id, newName, newType, newStatus, newDes, isRemoved } = req.body;
    let oldphotoUrl= await getAssetPhotoUrl(id);
    let photoUrl = oldphotoUrl;
    if (req.file) {
        try {
            if (oldphotoUrl) {
                let public_id_ary = oldphotoUrl.split('/').pop().split('.');
                public_id_ary.pop();
                const public_id = public_id_ary.join(".");
                await cloudinary.uploader.destroy(public_id);
            }
            const result = await cloudinary.uploader.upload(req.file.path,
                {
                    public_id: `${uuidv4()}-${req.file.originalname}`
                }
            );
            photoUrl = result.secure_url;
            fs.unlink(req.file.path, (err) => {
                if (err) console.error("Error deleting temporary file:", err);
            });
        } catch (error) {
            console.log(error);
            return res.status(500).send("Error uploading to Cloudinary");
        }
    }else if(isRemoved){
        if (oldphotoUrl) {
            let public_id_ary = oldphotoUrl.split('/').pop().split('.');
            public_id_ary.pop();
            const public_id = public_id_ary.join(".");
            await cloudinary.uploader.destroy(public_id);
        }
        photoUrl = null;
    }
    editAsset(id, newName, newType, newStatus, newDes, photoUrl, res);
})
app.post('/disable', (req, res)=>{
    const { id } = req.body;
    con.query("UPDATE assets SET status= ? WHERE id= ?;", ['disabled', id], (err, result)=>{
        if(err){
            return res.status(500).send("Server error");
        }else{
            return res.status(200).send("OK");
        }
    });
})
app.post('/return', authenticateToken, (req, res) => {
    const { transaction_id, asset_id } = req.body;
    const user = req.user;
    const today = new Date();
    const formattedDate = today.toISOString().split('T')[0];
    if (!transaction_id || !asset_id) {
        return res.status(400).send("Invalid input");
    }
    returnItem(asset_id, transaction_id, user.uid, formattedDate, res);
});
app.post('/takeout', authenticateToken, (req, res) => {
    const { transaction_id, asset_id } = req.body;
    const user = req.user;
    const today = new Date();
    const formattedDate = today.toISOString().split('T')[0];
    const nextWeek = new Date(today);
    nextWeek.setDate(today.getDate() + 7);
    const formattedNextWeek = nextWeek.toISOString().split('T')[0];
    if (!transaction_id || !asset_id) {
        return res.status(400).send("Invalid input");
    }
    takeoutItem(asset_id, transaction_id, user.uid, formattedDate, formattedNextWeek, res);
});
app.post('/addAsset', upload.single('photo'), async (req, res) => {
    const { newName, newType, newStatus, newDes } = req.body;
    let photoUrl = null;
    if (req.file) {
        try {
            const result = await cloudinary.uploader.upload(req.file.path,
                {
                    public_id: `${uuidv4()}-${req.file.originalname}`
                }
            );
            photoUrl = result.secure_url;
        } catch (error) {
            return res.status(500).send("Error uploading to Cloudinary");
        }
    }
    addAsset(newName, newType, newStatus, newDes, photoUrl, res);
})
app.post('/disableAsset', async (req, res) => {
    const { id } = req.body;
    con.query("UPDATE assets SET status= ? WHERE id= ?;", ["disabled", id], (err, result) => {
        if (err) {
            console.log(err);
            return res.status(500).send("sql error")
        }
        else if (result.affectedRows != 1) {
            console.log(result.affectedRows);
            return res.status(400).send("update fail");
        }
        res.status(200).send("Disable successful");
    });
})

app.get("/assets", (req, res) => {
    const sql = "SELECT assets.id, assets.name, assets.type_id, assets.status, assets.description, assets.image_url, asset_type.name AS type FROM assets LEFT JOIN asset_type ON assets.type_id = asset_type.id;";
    con.query(sql, (err, result) => {
        if (err) {
            console.log(err);
            return res.status(500).send("Server error")
        };
        res.status(200).json(result);
    });
});
app.get("/oneasset/:id", (req, res) => {
    const { id } = req.params;
    const sql = "SELECT * FROM assets WHERE id = ?";
    con.query(sql, [id], (err, result) => {
        if (err) {
            return res.status(500).send({ text: "Server error" });
        }
        if (result.length === 0) {
            return res.status(404).send({ text: "Asset not found" });
        }
        res.status(200).json(result[0]);
    });
});
app.get("/history/student", authenticateToken, (req, res) => {
    const user = req.user;
    getStudentHistory(user.uid, res);
});
app.get("/history/lecturer", authenticateToken, (req, res) => {
    const user = req.user;
    console.log(user);
    getLecturerHistory(user.uid, res);
});
app.get("/history/staff", (req, res) => {
    getStaffHistory(res);
});
app.get("/getRequest/student", authenticateToken, (req, res) => {
    const user = req.user;
    getRequestStudent(user.uid, res);
});
app.get("/getRequest/lecturer", (req, res) => {
    getRequestLecturer(res);
});
app.get("/manage/staff", (req, res) => {
    getManageStaff(res);
});
app.post('/borrow', authenticateToken, (req, res) => {
    const { asset_id, remark } = req.body;
    const user = req.user;
    console.log(user);
    const today = new Date();
    const borrow_date = today.toISOString().split('T')[0];
    today.setDate(today.getDate()+7);
    const expected_return_date= today.toISOString().split('T')[0];
    borrowItem(asset_id, user.uid, remark, borrow_date, expected_return_date, res);
})
app.post('/cancel', (req, res) => {
    const { transaction_id } = req.body;
    cancelItem(transaction_id, res);
})
app.post('/approve', authenticateToken, (req, res) => {
    const { transaction_id, asset_id } = req.body;
    const user = req.user;
    const today = new Date();
    const formattedDate = today.toISOString().split('T')[0];
    approveItem(transaction_id, asset_id, user.uid, formattedDate, res);
})
app.post('/reject', authenticateToken, (req, res) => {
    const { transaction_id, asset_id } = req.body;
    const user = req.user;
    const today = new Date();
    const formattedDate = today.toISOString().split('T')[0];
    rejectItem(transaction_id, asset_id, user.uid, formattedDate, res);
})
app.get('/getDashboard', (req, res) => {
    dashboard(res);
})
app.get('/getUser', authenticateToken, (req, res) => {
    const user = req.user;
    res.status(200).send({ "userId": user.uid, "username": user.username, "email": user.email, "role": user.role, "profile_pic": user.profile_pic, "student_id": user.student_id });
})
app.listen(3000, function () {
    console.log('Server is running at port 3000');
});