const mysql = require('mysql2');
const con= mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'asset_borrowing_system_mobile'
});

module.exports= con;