const con = require('../config/db');
var getStudentHistory = (student_id, res) =>{
  const sql = `
        SELECT 
          asset_transaction.borrow_date, 
          asset_transaction.expected_return_date,
          asset_transaction.returned_date, 
          assets.name AS asset_name, 
          asset_type.name AS asset_type,
          assets.image_url AS image,
          users.name,
          asset_transaction.status
        FROM 
          asset_transaction 
        JOIN 
          assets ON asset_transaction.asset_id = assets.id 
        JOIN 
          asset_type ON assets.type_id= asset_type.id
        JOIN 
          users ON asset_transaction.validator_id= users.id
        WHERE 
          asset_transaction.borrower_id = ? AND
          asset_transaction.status IN ('holding', 'returned')
        ORDER BY 
          asset_transaction.borrow_date DESC
      `;
  con.query(sql, [student_id], (err, results) => {
    if (err) {
      console.log(err);
      return res.status(500).send("Server error: " + err.message)
    };
    if (results.length === 0) return res.status(404).send("No History");
    res.status(200).json(results);
  });
}
var getLecturerHistory = (lecturer_id, res) => {
  const sql = `
  SELECT 
    asset_transaction.id,
    assets.name AS asset_name,
    asset_type.name AS asset_type,
    assets.image_url,
    users.name AS borrower_name,
    users.profile_pic AS borrower_profile,
    asset_transaction.status,
    asset_transaction.validated_date
  FROM 
    asset_transaction 
  JOIN 
    assets ON asset_transaction.asset_id = assets.id 
  JOIN 
    users ON asset_transaction.borrower_id = users.id 
  JOIN
    asset_type ON asset_type.id = assets.type_id
  WHERE 
    asset_transaction.validator_id = ? 
  ORDER BY 
    asset_transaction.validated_date DESC
`;

  con.query(sql, [lecturer_id], (err, results) => {
    if (err) {
      console.error("Database error:", err);
      return res.status(500).send("Server error");
    }

    if (results.length === 0) {
      return res
        .status(404)
        .send("No approved transaction history found for this lecturer");
    }

    res.status(200).json(results);
  });
}

var getStaffHistory = (res) => {
  const sql = `
  SELECT 
   asset_transaction.id,
   asset_transaction.asset_id,
   assets.name AS asset_name,
   asset_type.name AS asset_type,
   users.name AS borrower_name,
   users.profile_pic,
   asset_transaction.status
 FROM 
   asset_transaction 
 JOIN 
   assets ON asset_transaction.asset_id = assets.id 
 JOIN 
   users ON asset_transaction.borrower_id = users.id 
 JOIN
   asset_type ON assets.type_id = asset_type.id
 WHERE 
   asset_transaction.status NOT IN ('pending', 'holding', 'approved')
 ORDER BY 
   asset_transaction.borrow_date DESC
`;
  con.query(sql, (err, results) => {
    if (err) {
      console.error("Database error:", err);
      return res.status(500).send("Server error");
    }

    if (results.length === 0) {
      return res
        .status(404)
        .send("No transaction history found for this staff");
    }

    res.status(200).json(results);
  });
}

var getRequestStudent = (student_id, res) => {
  const sql = `
 SELECT 
   asset_transaction.id,
   asset_transaction.status,
   assets.name AS asset_name,
   assets.image_url AS image,
   asset_type.name AS asset_type,
   asset_transaction.borrower_id,
   asset_transaction.booked_date,
   asset_transaction.validator_id,
   asset_transaction.validated_date,
   asset_transaction.remark
 FROM 
   asset_transaction 
 JOIN 
   assets ON asset_transaction.asset_id = assets.id 
 JOIN
   asset_type ON assets.type_id= asset_type.id
 JOIN 
   users ON asset_transaction.borrower_id = users.id
 WHERE 
   asset_transaction.status IN ('pending', 'approved', 'disapproved') AND
   (asset_transaction.validated_date IS NULL OR asset_transaction.validated_date = CURDATE() OR asset_transaction.validated_date = CURDATE() - INTERVAl 1 DAY) AND
   asset_transaction.borrower_id= ?
 ORDER BY 
   asset_transaction.borrow_date DESC;
`;
  con.query(sql, [student_id], (err, results) => {
    if (err) {
      return res.status(500).send("Server error");
    };
    if (results.length === 0){
      return res.status(400).send("No request made");
    }
    res.status(200).json(results);
  });
}
var getRequestLecturer = (res) => {
  const sql = `
  SELECT 
   asset_transaction.id,
   asset_transaction.asset_id,
   asset_transaction.status,
   users.name AS borrower_name,
   users.profile_pic AS borrower_pic,
   asset_transaction.booked_date,
   asset_transaction.expected_return_date,
   assets.name AS asset_name,
   asset_type.name AS asset_type,
   users.name
 FROM 
   asset_transaction 
 JOIN 
   assets ON asset_transaction.asset_id = assets.id 
 JOIN 
   users ON asset_transaction.borrower_id = users.id 
 JOIN
   asset_type ON assets.type_id = asset_type.id
 WHERE 
   asset_transaction.status IN ('pending')
 ORDER BY 
   asset_transaction.borrow_date DESC
`;
  con.query(sql, (err, results) => {
    if (err) return res.status(500).send("Server error");
    if (results.length === 0) return res.status(400).send("No request made");
    res.status(200).json(results);
  });
}
var getManageStaff = (res) => {
  const sql = `
  SELECT 
    asset_transaction.id,
    asset_transaction.asset_id, 
    assets.name AS asset_name, 
    assets.image_url,
    asset_type.name AS asset_type,
    asset_transaction.validated_date, 
    asset_transaction.status, 
    users.name AS borrower_name,
    users.profile_pic
  FROM 
    asset_transaction 
  JOIN 
    assets ON asset_transaction.asset_id = assets.id 
  JOIN 
    users ON asset_transaction.borrower_id = users.id 
  JOIN 
    asset_type ON asset_type.id = assets.type_id
  WHERE  
    asset_transaction.status IN ('approved', 'holding') 
  ORDER BY 
    asset_transaction.borrow_date DESC
`;
  con.query(sql, (err, results) => {
    if (err) {
      console.error("Database error:", err);
      return res.status(500).send("Server error");
    }

    if (results.length === 0) {
      return res.status(404).send("No requests found for this staff member");
    }

    res.status(200).json(results);
  });
}

var dashboard = (res) => {
  con.query(`SELECT
    -- Total number of each asset type
    at.name AS asset_type,
    COUNT(a.id) AS total_assets,
    -- Breakdown by status
    SUM(CASE WHEN a.status = 'available' THEN 1 ELSE 0 END) AS available,
    SUM(CASE WHEN a.status = 'borrowed' THEN 1 ELSE 0 END) AS borrowed,
    SUM(CASE WHEN a.status = 'waiting' THEN 1 ELSE 0 END) AS waiting,
    SUM(CASE WHEN a.status = 'disabled' THEN 1 ELSE 0 END) AS disabled

FROM 
    assets a
JOIN 
    asset_type at ON a.type_id = at.id

GROUP BY 
    at.name
ORDER BY 
    at.name;
`, (err, result) => {
    if (err) return res.status(500).send("Server error");
    return res.status(200).json(result);
  });
}
const getProfilePhotoUrl = (id) => {
  return new Promise((resolve, reject) => {
      con.query("SELECT profile_pic FROM users WHERE id = ?", [id], (err, results) => {
          if (err) {
              console.error(err);
              reject("Server error");
          } else {
              if (results.length == 1) {
                  resolve(results[0].profile_pic);
              } else {
                  resolve(null);
              }
          }
      });
  });
};
const getAssetPhotoUrl= (id)=>{
  return new Promise((resolve, reject) => {
    con.query("SELECT image_url FROM assets WHERE id = ?", [id], (err, results) => {
        if (err) {
            console.error(err);
            reject("Server error");
        } else {
            if (results.length == 1) {
                resolve(results[0].image_url);
            } else {
                resolve(null);
            }
        }
    });
});
}
module.exports = {
  getStudentHistory,
  getLecturerHistory,
  getStaffHistory,
  getRequestStudent,
  getRequestLecturer,
  getManageStaff,
  dashboard,
  getProfilePhotoUrl,
  getAssetPhotoUrl
}