<div id="yewulControlCenter" style="background: #1a2635; padding: 30px; border-radius: 15px; margin: 20px; border: 2px dashed #f1c40f; text-align: center; font-family: sans-serif; color: white;">
    <h3 style="color: #f1c40f; margin-bottom: 20px;">📚 የመጽሐፍት አስተዳዳሪ (Admin)</h3>
    
    <div style="margin-bottom: 20px;">
        <input type="file" id="filePicker" style="margin-bottom: 15px;">
        <br>
        <button onclick="handleUpload()" id="mainBtn" style="background: #f1c40f; color: #1a2635; padding: 12px 30px; border: none; border-radius: 8px; cursor: pointer; font-weight: bold; font-size: 16px;">ፋይሉን ጫን</button>
    </div>

    <div id="loadingInfo" style="display: none; margin-top: 10px;">
        <div style="width: 100%; background: #2c3e50; height: 10px; border-radius: 5px; overflow: hidden;">
            <div id="pBar" style="width: 0%; height: 100%; background: #2ecc71; transition: 0.3s;"></div>
        </div>
        <p id="statusTxt" style="font-size: 14px; margin-top: 5px;">በመላክ ላይ...</p>
    </div>

    <hr style="border: 0.5px solid #2c3e50; margin: 25px 0;">

    <h4 style="text-align: left;">የተጫኑ ፋይሎች ዝርዝር፦</h4>
    <div id="fileList" style="text-align: left; background: #0d1621; padding: 15px; border-radius: 8px; min-height: 50px;">
        እየፈለገ ነው...
    </div>
</div>

<script type="module">
  import { initializeApp } from "https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js";
  import { getDatabase, ref, set, push, onValue, remove } from "https://www.gstatic.com/firebasejs/10.7.1/firebase-database.js";

  // ያንተ Firebase Config
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

  // Cloudinary መረጃ
  const CLOUD_NAME = "dsbvs1h3w"; //
  const UPLOAD_PRESET = "yewul_preset"; //

  // --- ፋይል መጫኛ ተግባር ---
  window.handleUpload = async function() {
    const file = document.getElementById('filePicker').files[0];
    if (!file) return alert("እባክህ መጀመሪያ ፋይል ምረጥ!");

    const btn = document.getElementById('mainBtn');
    const loadingInfo = document.getElementById('loadingInfo');
    const pBar = document.getElementById('pBar');
    const statusTxt = document.getElementById('statusTxt');

    btn.disabled = true;
    loadingInfo.style.display = "block";
    pBar.style.width = "50%"; // ግማሽ ደርሷል ለማለት

    const formData = new FormData();
    formData.append('file', file);
    formData.append('upload_preset', UPLOAD_PRESET);

    try {
        const response = await fetch(`https://api.cloudinary.com/v1_1/${CLOUD_NAME}/auto/upload`, {
            method: 'POST',
            body: formData
        });

        const data = await response.json();

        if (data.secure_url) {
            // Cloudinary ላይ ከተጫነ በኋላ መረጃውን Firebase ውስጥ መመዝገብ
            const bookRef = push(ref(db, 'books'));
            await set(bookRef, {
                fileName: file.name,
                fileUrl: data.secure_url,
                publicId: data.public_id // ለማጥፋት ይረዳናል
            });

            pBar.style.width = "100%";
            statusTxt.innerText = "በተሳካ ሁኔታ ተጭኗል! ✅";
            setTimeout(() => { loadingInfo.style.display = "none"; pBar.style.width = "0%"; }, 2000);
            btn.disabled = false;
        }
    } catch (err) {
        alert("ስህተት: " + err.message);
        btn.disabled = false;
    }
  };

  // --- ዝርዝሩን ከ Firebase አምጥቶ ማሳያ እና ማጥፊያ ---
  const fileListDiv = document.getElementById('fileList');
  onValue(ref(db, 'books'), (snapshot) => {
    fileListDiv.innerHTML = "";
    const data = snapshot.val();
    if (data) {
        Object.keys(data).forEach(id => {
            const item = data[id];
            const div = document.createElement('div');
            div.style = "display: flex; justify-content: space-between; padding: 10px; border-bottom: 1px solid #2c3e50; align-items: center;";
            div.innerHTML = `
                <span style="font-size: 14px;">📄 ${item.fileName}</span>
                <div>
                    <a href="${item.fileUrl}" target="_blank" style="color: #2ecc71; text-decoration: none; margin-right: 15px; font-size: 13px;">ክፈት</a>
                    <button onclick="deleteFile('${id}')" style="background: #e74c3c; color: white; border: none; padding: 5px 10px; border-radius: 4px; cursor: pointer; font-size: 12px;">አጥፋ</button>
                </div>
            `;
            fileListDiv.appendChild(div);
        });
    } else {
        fileListDiv.innerHTML = "ምንም የተጫነ ፋይል የለም።";
    }
  });

  // --- ማጥፊያ ተግባር ---
  window.deleteFile = function(id) {
    if (confirm("ይህ ፋይል ከዝርዝሩ ይጥፋ?")) {
        remove(ref(db, 'books/' + id))
        .then(() => alert("ተሰርዟል!"))
        .catch(err => alert("ስህተት: " + err.message));
    }
  };
</script>
