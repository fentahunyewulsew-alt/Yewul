<!DOCTYPE html>
<html lang="am">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Yewul Platform</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        :root { --bg: #0d1621; --card: #1a2635; --accent: #f1c40f; --blue: #2563eb; }
        body { font-family: 'Segoe UI', sans-serif; background: var(--bg); color: white; margin: 0; padding: 20px; text-align: center; }
        
        /* Header Section */
        .header { position: relative; margin-bottom: 20px; }
        .settings-icon { position: absolute; right: 0; top: 0; color: #7f8c8d; font-size: 28px; cursor: pointer; z-index: 100; }
        .logo-img { width: 140px; height: 140px; border-radius: 50%; border: 4px solid var(--accent); object-fit: cover; background: #2c3e50; }
        .estab-year { color: var(--accent); font-size: 14px; margin-top: 5px; font-weight: bold; }

        /* Search Bar */
        .search-box { background: #162130; border: 1px solid #2c3e50; border-radius: 8px; padding: 12px; width: 90%; max-width: 500px; margin: 15px auto; color: white; display: block; outline: none; }

        /* Book Items */
        .book-item { background: var(--card); border-radius: 12px; padding: 15px; margin: 12px auto; max-width: 500px; display: flex; justify-content: space-between; align-items: center; border: 1px solid #2c3e50; }
        .book-info { font-weight: bold; text-align: left; font-size: 16px; flex-grow: 1; color: #ecf0f1; }
        .btn-group { display: flex; gap: 8px; }
        .btn-read, .btn-down { padding: 7px 14px; border-radius: 6px; text-decoration: none; font-weight: bold; font-size: 12px; transition: 0.2s; border: none; cursor: pointer; }
        .btn-read { background: var(--accent); color: #000; }
        .btn-down { background: var(--blue); color: #fff; }
        .btn-read:hover, .btn-down:hover { opacity: 0.8; }

        /* Modal Settings */
        .modal { display: none; position: fixed; z-index: 2000; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.95); overflow-y: auto; }
        .modal-content { background: var(--card); margin: 5% auto; padding: 25px; width: 85%; max-width: 420px; border-radius: 20px; border: 2px solid var(--accent); text-align: left; position: relative; }
        .close-btn { position: absolute; right: 20px; top: 15px; font-size: 30px; cursor: pointer; color: white; }
        
        .admin-btn { background: var(--accent); color: #000; border: none; padding: 12px; width: 100%; border-radius: 10px; font-weight: bold; cursor: pointer; margin-top: 10px; display: block; }
        #adminList { max-height: 180px; overflow-y: auto; background: #0d1621; border-radius: 10px; padding: 5px; margin-top: 10px; }
        .admin-item { display: flex; justify-content: space-between; padding: 8px; border-bottom: 1px solid #2c3e50; font-size: 13px; align-items: center; }
        .btn-del { background: #e74c3c; color: white; border: none; padding: 4px 10px; border-radius: 5px; cursor: pointer; }
    </style>
</head>
<body>

    <div class="header">
        <i class="fas fa-cog settings-icon" onclick="document.getElementById('setMod').style.display='block'"></i>
        <img src="https://via.placeholder.com/150" alt="Profile" class="logo-img">
        <h1 id="mainTitle">Yewul Platform</h1>
        <div class="estab-year">የተመሰረተበት 2018 ዓ.ም</div>
        <hr style="border: 1px solid var(--accent); width: 80%; margin: 15px auto;">
    </div>

    <input type="text" id="search" class="search-box" placeholder="መጽሐፍት እዚህ ይፈልጉ..." onkeyup="searchBooks()">

    <div id="booksWrapper">
        <div class="book-item" data-name="መጽሐፍ ቅዱስ bible">
            <div class="book-info" id="b1">መጽሐፍ ቅዱስ (Bible)</div>
            <div class="btn-group"><a href="#" class="btn-read">Read</a><a href="#" class="btn-down">Download</a></div>
        </div>
        <div class="book-item" data-name="ጉባኤ ኒቅያ nicaea">
            <div class="book-info" id="b2">ጉባኤ ኒቅያ (Nicaea)</div>
            <div class="btn-group"><a href="#" class="btn-read">Read</a><a href="#" class="btn-down">Download</a></div>
        </div>
        <div id="dynamicContainer"></div>
    </div>

    <div id="setMod" class="modal">
        <div class="modal-content">
            <span class="close-btn" onclick="document.getElementById('setMod').style.display='none'">&times;</span>
            <h3 style="color:var(--accent)"><i class="fas fa-sliders-h"></i> ሴቲንግ</h3>
            
            <label>🌐 ቋንቋ መቀየሪያ</label>
            <select id="langSelect" onchange="changeLanguage()" style="width:100%; padding:10px; margin-bottom:15px; border-radius:8px;">
                <option value="am">አማርኛ</option>
                <option value="en">English</option>
                <option value="ge">ግዕዝ</option>
                <option value="ar">Arabic</option>
                <option value="sp">Spanish</option>
            </select>

            <label>📤 አዲስ ፋይል ጫን</label>
            <input type="file" id="fPick" style="margin-top:5px; width:100%;">
            <button class="admin-btn" onclick="uploadToCloud()">ወደ ሰርቨር ላክ</button>
            <p id="upStatus" style="font-size:11px; text-align:center; color:var(--accent)"></p>

            <label>🗑️ ፋይሎችን አጥፋ</label>
            <div id="adminList"></div>

            <a href="https://t.me/sew_alt" target="_blank" style="display:block; text-align:center; color:#0088cc; margin-top:15px; text-decoration:none;">
                <i class="fab fa-telegram-plane"></i> ቴሌግራም ያግኙን
            </a>
        </div>
    </div>

    <script type="module">
        import { initializeApp } from "https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js";
        import { getDatabase, ref, set, push, onValue, remove } from "https://www.gstatic.com/firebasejs/10.7.1/firebase-database.js";

        const firebaseConfig = {
            apiKey: "AIzaSyD0aNWGu5ks476yfm4Q-FLxepkSWtYAJcI",
            authDomain: "yewul-platform.firebaseapp.com",
            projectId: "yewul-platform",
            databaseURL: "https://yewul-platform-default-rtdb.firebaseio.com",
            storageBucket: "yewul-platform.firebasestorage.app",
            messagingSenderId: "731322746896",
            appId: "1:731322746896:web:a2a9e7d9f0769b366d2295"
        };

        const app = initializeApp(firebaseConfig);
        const db = getDatabase(app);

        // --- ሰርች ባር እንዲሰራ ---
        window.searchBooks = function() {
            let input = document.getElementById('search').value.toLowerCase();
            let items = document.getElementsByClassName('book-item');
            for (let i = 0; i < items.length; i++) {
                let name = items[i].getAttribute('data-name') || items[i].innerText.toLowerCase();
                items[i].style.display = name.includes(input) ? "flex" : "none";
            }
        };

        // --- ፋይል መጫኛ ---
        window.uploadToCloud = async function() {
            const file = document.getElementById('fPick').files[0];
            if(!file) return alert("ፋይል ምረጥ!");
            document.getElementById('upStatus').innerText = "እየተጫነ ነው...";
            
            const formData = new FormData();
            formData.append('file', file);
            formData.append('upload_preset', 'yewul_preset');

            try {
                const res = await fetch(`https://api.cloudinary.com/v1_1/dsbvs1h3w/auto/upload`, {method:'POST', body:formData});
                const data = await res.json();
                if(data.secure_url) {
                    await set(push(ref(db, 'books')), { name: file.name, url: data.secure_url });
                    document.getElementById('upStatus').innerText = "ተሳክቷል! ✅";
                }
            } catch(e) { document.getElementById('upStatus').innerText = "አልተሳካም!"; }
        };

        // --- ዳታ ማሳያ እና ማጥፊያ ---
        onValue(ref(db, 'books'), (snap) => {
            const container = document.getElementById('dynamicContainer');
            const adminList = document.getElementById('adminList');
            container.innerHTML = ""; adminList.innerHTML = "";
            const data = snap.val();
            if(data) {
                Object.keys(data).forEach(id => {
                    container.innerHTML += `<div class="book-item" data-name="${data[id].name.toLowerCase()}">
                        <div class="book-info">${data[id].name}</div>
                        <div class="btn-group"><a href="${data[id].url}" class="btn-read" target="_blank">Read</a><a href="${data[id].url}" class="btn-down" download>Download</a></div>
                    </div>`;
                    adminList.innerHTML += `<div class="admin-item"><span>${data[id].name}</span><button class="btn-del" onclick="delBook('${id}')">አጥፋ</button></div>`;
                });
            }
        });

        window.delBook = (id) => { if(confirm("ይጥፋ?")) remove(ref(db, 'books/'+id)); };

        // --- ቋንቋ መቀየሪያ ---
        window.changeLanguage = function() {
            const l = document.getElementById('langSelect').value;
            const t = { am: ["መጽሐፍ ቅዱስ", "ጉባኤ ኒቅያ"], en: ["The Bible", "Council of Nicaea"], ar: ["الكتاب المقدس", "مجمع نيقية"] };
            if(t[l]) { document.getElementById('b1').innerText = t[l][0]; document.getElementById('b2').innerText = t[l][1]; }
        };
    </script>
</body>
</html>
