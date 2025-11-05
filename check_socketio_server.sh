- đây đọc đi : PS C:\Users\ACER> ssh -p 2222 root@167.179.110.50
root@167.179.110.50's password:
Last login: Wed Nov  5 14:48:09 2025 from 104.28.211.57
[root@socdo home]# find /etc/nginx -name "*chat*" -type f
/etc/nginx/config-https/chat.trungtamkcnphutho.vn-https.conf
/etc/nginx/config-https/chat.socdo.vn-https.conf
/etc/nginx/conf.d/chat.socdo.vn.conf
/etc/nginx/conf.d/chat.giadungluxury.com.conf
/etc/nginx/conf.d/chat.trungtamkcnphutho.vn.conf
[root@socdo home]# cat /etc/nginx/sites-available/chat.socdo.vn
cat: /etc/nginx/sites-available/chat.socdo.vn: No such file or directory
[root@socdo home]# # Hoặc:
[root@socdo home]# cat /etc/nginx/conf.d/chat.socdo.vn.conf
server {
        listen 80;

        server_name www.chat.socdo.vn;
        rewrite ^(.*) https://chat.socdo.vn$1 permanent;
}

server {
        listen 80;

        # access_log off;
        access_log /home/chat.socdo.vn/logs/access.log;
        # error_log off;
        error_log /home/chat.socdo.vn/logs/error.log;

        root /home/chat.socdo.vn/public_html;
        index index.php index.html index.htm;
        server_name chat.socdo.vn;

        # Config wordpress + Plugin wp super cache
        #include /etc/nginx/conf.d/supercache.conf;

        # Config wordpress + Plugin W3 Total Cache
        #include /etc/nginx/conf.d/w3total.conf;

        # Config wordpress + Plugin WP-Rocket
        #include /etc/nginx/conf.d/wprocket.conf;

        # Config wordpress + Plugin wp fastest cache
        #include /etc/nginx/conf.d/wp-fastest-cache.conf;

        # Custom configuration
#       include /home/chat.socdo.vn/public_html/*.conf;

#       location / {
#               try_files $uri $uri/ /index.php?$args;
#       }
 location ~/socket\.io.*$ {
  proxy_pass         http://127.0.0.1:3000;
  proxy_http_version 1.1;
  proxy_set_header   Upgrade    $http_upgrade;
  proxy_set_header   Connection "upgrade";
}
location / {
    proxy_pass http://localhost:3000;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
    proxy_cache_bypass $http_upgrade;
}
        location ~ \.php$ {
                fastcgi_split_path_info ^(.+\.php)(/.+)$;
                include /etc/nginx/fastcgi_params;
                fastcgi_pass 127.0.0.1:9000;
                fastcgi_index index.php;
                fastcgi_connect_timeout 300;
                fastcgi_send_timeout 300;
                fastcgi_read_timeout 300;
                fastcgi_buffer_size 32k;
                fastcgi_buffers 8 16k;
                fastcgi_busy_buffers_size 32k;
                fastcgi_temp_file_write_size 32k;
                fastcgi_intercept_errors on;
                fastcgi_param SCRIPT_FILENAME /home/chat.socdo.vn/public_html$fastcgi_script_name;
        }

        # Disable .htaccess and other hidden files
        location ~ /\.(?!well-known).* {
                deny all;
                access_log off;
                log_not_found off;
        }

        location = /favicon.ico {
                log_not_found off;
                access_log off;
        }

        location = /robots.txt {
                allow all;
                log_not_found off;
                access_log off;
        }
        location ~* \.(js|json)$ {
                add_header 'Access-Control-Allow-Origin' "$http_origin" always;
                add_header 'Access-Control-Allow-Methods' 'GET, OPTIONS' always;
                add_header 'Access-Control-Allow-Headers' 'Content-Type' always;
                if ($http_origin ~* "(socdo\.vn|beta\.socdo\.vn|beta\.vn|socmoi\.vn|tongkhohang\.vn)$") {
                        add_header 'Access-Control-Allow-Origin' "$http_origin";
                }
        }
        location ~* \.(3gp|gif|jpg|jpeg|png|ico|wmv|avi|asf|asx|mpg|mpeg|mp4|pls|mp3|mid|wav|swf|flv|exe|zip|tar|rar|gz|tgz|bz2|uha|7z|doc|docx|xls|xlsx|pdf|iso|eot|svg|ttf|woff)$ {
                gzip_static off;
                add_header Pragma public;
                add_header Cache-Control "public, must-revalidate, proxy-revalidate";
                access_log off;
                expires 30d;
                break;
        }

        location ~* \.(txt|js|css)$ {
                add_header Pragma public;
                add_header Cache-Control "public, must-revalidate, proxy-revalidate";
                access_log off;
                expires 30d;
                break;
        }
}
[root@socdo home]# ps aux | grep 355
root       355  0.3  1.3 925008 51872 ?        Ssl  Oct10 113:09 node /home/chat.trungtamkcnphutho.vn/public_html/index.js
root     16432  0.0  0.0 112812   972 pts/0    S+   14:50   0:00 grep --color=auto 355
[root@socdo home]# lsof -i :3000
COMMAND  PID  USER   FD   TYPE   DEVICE SIZE/OFF NODE NAME
node     355  root   19u  IPv6 17438318      0t0  TCP localhost:hbci->localhost:41888 (ESTABLISHED)
node     355  root   20u  IPv6  3577433      0t0  TCP *:hbci (LISTEN)
node     355  root   22u  IPv6 17390580      0t0  TCP localhost:hbci->localhost:54476 (ESTABLISHED)
node     355  root   24u  IPv6 17445168      0t0  TCP localhost:hbci->localhost:43318 (ESTABLISHED)
node     355  root   25u  IPv6 17384583      0t0  TCP localhost:hbci->localhost:52420 (ESTABLISHED)
node     355  root   26u  IPv6 17427082      0t0  TCP localhost:hbci->localhost:38318 (ESTABLISHED)
node     355  root   27u  IPv6 17437548      0t0  TCP localhost:hbci->localhost:41890 (ESTABLISHED)
node     355  root   28u  IPv6 17388984      0t0  TCP localhost:hbci->localhost:54092 (ESTABLISHED)
node     355  root   29u  IPv6 17406892      0t0  TCP localhost:hbci->localhost:60332 (ESTABLISHED)
node     355  root   30u  IPv6 17424550      0t0  TCP localhost:hbci->localhost:37274 (ESTABLISHED)
node     355  root   31u  IPv6 17444850      0t0  TCP localhost:hbci->localhost:43320 (ESTABLISHED)
node     355  root   33u  IPv6 17431768      0t0  TCP localhost:hbci->localhost:39622 (ESTABLISHED)
node     355  root   34u  IPv6 17428316      0t0  TCP localhost:hbci->localhost:38690 (ESTABLISHED)
node     355  root   35u  IPv6 17411699      0t0  TCP localhost:hbci->localhost:33286 (ESTABLISHED)
node     355  root   36u  IPv6 17442013      0t0  TCP localhost:hbci->localhost:42440 (ESTABLISHED)
node     355  root   37u  IPv6 17417817      0t0  TCP localhost:hbci->localhost:35330 (ESTABLISHED)
node     355  root   38u  IPv6 17392399      0t0  TCP localhost:hbci->localhost:55020 (ESTABLISHED)
node     355  root   39u  IPv6 17432809      0t0  TCP localhost:hbci->localhost:40240 (ESTABLISHED)
node     355  root   40u  IPv6 17432813      0t0  TCP localhost:hbci->localhost:40244 (ESTABLISHED)
node     355  root   41u  IPv6 17440195      0t0  TCP localhost:hbci->localhost:42242 (ESTABLISHED)
node     355  root   43u  IPv6 17392831      0t0  TCP localhost:hbci->localhost:55182 (ESTABLISHED)
node     355  root   44u  IPv6 17418600      0t0  TCP localhost:hbci->localhost:35224 (ESTABLISHED)
node     355  root   45u  IPv6 17394538      0t0  TCP localhost:hbci->localhost:55820 (ESTABLISHED)
node     355  root   46u  IPv6 17431950      0t0  TCP localhost:hbci->localhost:39728 (ESTABLISHED)
node     355  root   47u  IPv6 17392355      0t0  TCP localhost:hbci->localhost:54996 (ESTABLISHED)
node     355  root   48u  IPv6 17422856      0t0  TCP localhost:hbci->localhost:36888 (ESTABLISHED)
node     355  root   49u  IPv6 17422858      0t0  TCP localhost:hbci->localhost:36890 (ESTABLISHED)
node     355  root   51u  IPv6 17440619      0t0  TCP localhost:hbci->localhost:42492 (ESTABLISHED)
node     355  root   52u  IPv6 17428241      0t0  TCP localhost:hbci->localhost:38636 (ESTABLISHED)
node     355  root   53u  IPv6 17428759      0t0  TCP localhost:hbci->localhost:38810 (ESTABLISHED)
node     355  root   54u  IPv6 17421207      0t0  TCP localhost:hbci->localhost:36374 (ESTABLISHED)
node     355  root   55u  IPv6 17431103      0t0  TCP localhost:hbci->localhost:39732 (ESTABLISHED)
node     355  root   56u  IPv6 17431955      0t0  TCP localhost:hbci->localhost:39734 (ESTABLISHED)
node     355  root   57u  IPv6 17431113      0t0  TCP localhost:hbci->localhost:39740 (ESTABLISHED)
node     355  root   58u  IPv6 17398738      0t0  TCP localhost:hbci->localhost:57514 (ESTABLISHED)
node     355  root   59u  IPv6 17443073      0t0  TCP localhost:hbci->localhost:42738 (ESTABLISHED)
node     355  root   60u  IPv6 17443077      0t0  TCP localhost:hbci->localhost:42740 (ESTABLISHED)
node     355  root   61u  IPv6 17429522      0t0  TCP localhost:hbci->localhost:38822 (ESTABLISHED)
node     355  root   63u  IPv6 17429572      0t0  TCP localhost:hbci->localhost:38864 (ESTABLISHED)
node     355  root   67u  IPv6 17429723      0t0  TCP localhost:hbci->localhost:38972 (ESTABLISHED)
nginx   8064 nginx    6u  IPv4 17389948      0t0  TCP localhost:54092->localhost:hbci (ESTABLISHED)
nginx   8064 nginx    7u  IPv4 17389528      0t0  TCP localhost:54476->localhost:hbci (ESTABLISHED)
nginx   8064 nginx   66u  IPv4 17439347      0t0  TCP localhost:42242->localhost:hbci (ESTABLISHED)
nginx   8064 nginx   74u  IPv4 17427726      0t0  TCP localhost:38318->localhost:hbci (ESTABLISHED)
nginx   8064 nginx   75u  IPv4 17437547      0t0  TCP localhost:41888->localhost:hbci (ESTABLISHED)
nginx   8064 nginx   76u  IPv4 17431099      0t0  TCP localhost:39728->localhost:hbci (ESTABLISHED)
nginx   8064 nginx   78u  IPv4 17445171      0t0  TCP localhost:43320->localhost:hbci (ESTABLISHED)
nginx   8064 nginx   79u  IPv4 17423870      0t0  TCP localhost:37274->localhost:hbci (ESTABLISHED)
nginx   8064 nginx   84u  IPv4 17392608      0t0  TCP localhost:55182->localhost:hbci (ESTABLISHED)
nginx   8064 nginx   85u  IPv4 17408152      0t0  TCP localhost:60332->localhost:hbci (ESTABLISHED)
nginx   8064 nginx   87u  IPv4 17433760      0t0  TCP localhost:40240->localhost:hbci (ESTABLISHED)
nginx   8064 nginx   93u  IPv4 17421445      0t0  TCP localhost:36374->localhost:hbci (ESTABLISHED)
nginx   8064 nginx   96u  IPv4 17433767      0t0  TCP localhost:40244->localhost:hbci (ESTABLISHED)
nginx   8064 nginx   98u  IPv4 17399273      0t0  TCP localhost:57514->localhost:hbci (ESTABLISHED)
nginx   8064 nginx  102u  IPv4 17431106      0t0  TCP localhost:39734->localhost:hbci (ESTABLISHED)
nginx   8064 nginx  112u  IPv4 17428955      0t0  TCP localhost:38972->localhost:hbci (ESTABLISHED)
nginx   8064 nginx  118u  IPv4 17442588      0t0  TCP localhost:42740->localhost:hbci (ESTABLISHED)
nginx   8065 nginx   54u  IPv4 17430938      0t0  TCP localhost:39622->localhost:hbci (ESTABLISHED)
nginx   8065 nginx   59u  IPv4 17438321      0t0  TCP localhost:41890->localhost:hbci (ESTABLISHED)
nginx   8065 nginx   65u  IPv4 17418814      0t0  TCP localhost:35330->localhost:hbci (ESTABLISHED)
nginx   8065 nginx   71u  IPv4 17384026      0t0  TCP localhost:52420->localhost:hbci (ESTABLISHED)
nginx   8065 nginx   72u  IPv4 17440527      0t0  TCP localhost:42440->localhost:hbci (ESTABLISHED)
nginx   8065 nginx   74u  IPv4 17391497      0t0  TCP localhost:54996->localhost:hbci (ESTABLISHED)
nginx   8065 nginx   78u  IPv4 17428618      0t0  TCP localhost:38690->localhost:hbci (ESTABLISHED)
nginx   8065 nginx   80u  IPv4 17442116      0t0  TCP localhost:42492->localhost:hbci (ESTABLISHED)
nginx   8065 nginx   81u  IPv4 17428769      0t0  TCP localhost:38822->localhost:hbci (ESTABLISHED)
nginx   8065 nginx   82u  IPv4 17442586      0t0  TCP localhost:42738->localhost:hbci (ESTABLISHED)
nginx   8065 nginx   87u  IPv4 17391533      0t0  TCP localhost:55020->localhost:hbci (ESTABLISHED)
nginx   8065 nginx   88u  IPv4 17412315      0t0  TCP localhost:33286->localhost:hbci (ESTABLISHED)
nginx   8065 nginx   89u  IPv4 17444848      0t0  TCP localhost:43318->localhost:hbci (ESTABLISHED)
nginx   8065 nginx   91u  IPv4 17428557      0t0  TCP localhost:38636->localhost:hbci (ESTABLISHED)
nginx   8065 nginx   95u  IPv4 17429507      0t0  TCP localhost:38810->localhost:hbci (ESTABLISHED)
nginx   8065 nginx   97u  IPv4 17394881      0t0  TCP localhost:55820->localhost:hbci (ESTABLISHED)
nginx   8065 nginx  101u  IPv4 17422166      0t0  TCP localhost:36888->localhost:hbci (ESTABLISHED)
nginx   8065 nginx  103u  IPv4 17417623      0t0  TCP localhost:35224->localhost:hbci (ESTABLISHED)
nginx   8065 nginx  109u  IPv4 17422168      0t0  TCP localhost:36890->localhost:hbci (ESTABLISHED)
nginx   8065 nginx  122u  IPv4 17428820      0t0  TCP localhost:38864->localhost:hbci (ESTABLISHED)
nginx   8065 nginx  139u  IPv4 17431954      0t0  TCP localhost:39732->localhost:hbci (ESTABLISHED)
nginx   8065 nginx  142u  IPv4 17431112      0t0  TCP localhost:39740->localhost:hbci (ESTABLISHED)
[root@socdo home]#
- PS C:\Users\ACER> ssh -p 2222 root@167.179.110.50
root@167.179.110.50's password:
Last login: Wed Nov  5 14:44:31 2025 from 104.28.211.57
[root@socdo home]# cat /home/chat.socdo.vn/public_html/index.js
var express = require("express");
var mysql = require("mysql");
var con = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "Qaz!@#123",
  database: "gara"
});
var app = express();
var date_post = Date.now();
app.use(express.static("./public"));
app.set("view engine","ejs");
app.set("views","./views");
var server = require("http").Server(app);
var io = require("socket.io")(server, {
  cors: {
    origin: "*", // ✅ Cho phép tất cả origins (mobile + web)
    methods: ["GET", "POST"],
    allowedHeaders: ["*"],
    credentials: true
  },
  transports: ["websocket", "polling"], // ✅ Support cả websocket và polling
  allowEIO3: true // ✅ Support Socket.IO client cũ
});
server.listen(process.env.PORT || 3000);
var listuser=[];
io.on("connection",function(socket){
        //console.log('co nguoi ket noi');
        socket.on("disconnect",function(){
                listuser.splice(listuser.indexOf(socket.id),1);
                io.sockets.emit("server_send_offline",socket.id);
                //io.sockets.emit("server_send_online",listuser);
                //console.log(socket.id+" ngat ket noi");
        });
        ////////////////////////
        socket.on("show_box_chat",function(data){
                info=JSON.parse(data);
                io.sockets.emit("get_box_chat",data);
                //io.to(info.user_in).emit("get_box_chat",data);
        });
        socket.on("user_send_dong_yeucau",function(data){
                info=JSON.parse(data);
                io.sockets.emit("server_send_dong_yeucau",data);
        });
        socket.on("user_send_list_yeucau",function(data){
                info=JSON.parse(data);
                io.sockets.emit("server_send_list_yeucau",data);
        });
        socket.on("user_send_traodoi",function(data){
                info=JSON.parse(data);
                io.sockets.emit("server_send_traodoi",data);
        });
        socket.on("user_traodoi_chating",function(data){
                info=JSON.parse(data);
                io.sockets.emit("server_send_traodoi_chating",data);
                //io.to(info.user_in).emit('server_send_chating',data);
        });
        socket.on("user_stop_tradoi",function(data){
                info=JSON.parse(data);
                io.sockets.emit("server_send_stop_traodoi",data);
                //io.to(info.user_in).emit("server_send_stop_chat",data);
        });
        socket.on("load_traodoi",function(data){
                io.sockets.emit("server_send_traodoi",data);
        });
        socket.on("user_send_chat",function(data){
                info=JSON.parse(data);
                io.sockets.emit("server_send_chat",data);
                //io.to(info.user_in).emit('server_send_chat',data);
        });

        socket.on("user_chating",function(data){
                info=JSON.parse(data);
                io.sockets.emit("server_send_chating",data);
                //io.to(info.user_in).emit('server_send_chating',data);
        });
        socket.on("user_stop_chat",function(data){
                info=JSON.parse(data);
                io.sockets.emit("server_send_stop_chat",data);
                //io.to(info.user_in).emit("server_send_stop_chat",data);
        });
        socket.on("load_chat",function(data){
                io.sockets.emit("server_send_chat",data);
        });
        socket.on("user_send_note",function(data){
                io.sockets.emit("server_send_note",data);
        });
        socket.on("user_send_hoatdong",function(data){
                io.sockets.emit("server_send_hoatdong",data);
                //console.log('Tiếp nhận xe');
        });
        socket.on("user_online",function(data){
                //info=JSON.parse(data);
                //socket.join(info.user_online);
                //io.sockets.emit("get_notice",data);
                //socket.id=info.user_online;
                //console.log('socket.id: '+socket.id);
                if(listuser.indexOf(socket.id)>=0){
                }else{
                        listuser.push(socket.id);
                }
                io.sockets.emit("server_send_online",listuser);
                //console.log(socket.adapter.rooms);
        });
        // --- CHAT NCC/Khách hàng realtime ---
        socket.on('client_send_message', function(data) {
                // data: {session_id, ncc_id, message}
                io.sockets.emit('server_send_message', {
                        session_id: data.session_id,
                        ncc_id: data.ncc_id,
                        message: data.message,
                        time: (new Date()).toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' }),
                        is_me: false // phía client sẽ xác định lại
                });
        });
        socket.on('ncc_send_message', function(data) {
                // data: {session_id, customer_id, message}
                io.sockets.emit('server_send_message', {
                        session_id: data.session_id,
                        customer_id: data.customer_id,
                        message: data.message,
                        time: (new Date()).toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' }),
                        is_me: false
                });
        });
/*              var chon_thongbao = setInterval(function(){
                  con.query("SELECT * FROM tiepnhan_khach WHERE status ='0' AND covan_nhan='0' ORDER BY id ASC LIMIT 1", function (err, thongtin_cho) {
                    if (err) throw err;
                    total_cho = thongtin_cho.length;
                    if(total_cho==0){
                        clearInterval(chon_thongbao);
                    }else{
                            var string=JSON.stringify(thongtin_cho);
                            var info =  JSON.parse(string);
                                con.query("SELECT * FROM voc WHERE dien_thoai='"+info[0].dien_thoai+"' OR bks='"+info[0].xe+"'", function (err, thongtin_voc) {
                                    if (err) throw err;
                                    total_voc = thongtin_voc.length;
                                    if(total_voc==0){
                                                con.query("SELECT * FROM nhan_su WHERE nhom='covan' AND (SELECT count(*) FROM tiepnhan_khach WHERE tiepnhan_khach.covan_nhan=nhan_su.user_id AND status='0')<2 AND busy='0' ORDER BY name ASC LIMIT 1", function (err, thongtin_covan) {
                                                    if (err) throw err;
                                                    total_covan = thongtin_covan.length;
                                                    if(total_covan==0){

                                                    }else{
                                                            var string_covan=JSON.stringify(thongtin_covan);
                                                            var info_covan =  JSON.parse(string_covan);
                                                            console.log(info_covan);
                                                    }
                                                });
                                    }else{
                                            var list_voc='';
                                                for (var i = 0; i < total_voc; i++) {
                                                  if(i==0){
                                                        list_voc+=info[i].user_id
                                                  }else{
                                                        list_voc+=','+info[i].user_id;
                                                  }
                                                }
                                                con.query("SELECT * FROM nhan_su WHERE nhom='covan' AND user_id NOT IN ("+list_voc+") AND (SELECT count(*) FROM tiepnhan_khach WHERE tiepnhan_khach.covan_nhan=nhan_su.user_id AND status='0')<2 AND busy='0' ORDER BY rand() ASC LIMIT 1", function (err, thongtin_covan) {
                                                    if (err) throw err;
                                                    total_covan = thongtin_covan.length;
                                                    if(total_covan==0){

                                                    }else{
                                                            var string_covan=JSON.stringify(thongtin_covan);
                                                            var info_covan =  JSON.parse(string_covan);
                                                    }
                                                });
                                    }
                                });
                    }
                  });
                },5e3);*/
/*      setInterval(function(){
                io.sockets.emit("server_send_online");
        },120e3);*/
});
app.get("/", function(req,res){
        res.render('trangchu');
});
[root@socdo home]# pm2 describe 0
m2 describe 1 Describing process with id 0 - name index
┌───────────────────┬──────────────────────────────────────────┐
│ status            │ errored                                  │
│ name              │ index                                    │
│ namespace         │ default                                  │
│ version           │ 1.0.0                                    │
│ restarts          │ 16                                       │
│ uptime            │ 0                                        │
│ script path       │ /home/chat.socdo.vn/public_html/index.js │
│ script args       │ N/A                                      │
│ error log path    │ /root/.pm2/logs/index-error.log          │
│ out log path      │ /root/.pm2/logs/index-out.log            │
│ pid path          │ /root/.pm2/pids/index-0.pid              │
│ interpreter       │ node                                     │
│ interpreter args  │ N/A                                      │
│ script id         │ 0                                        │
│ exec cwd          │ /home/chat.socdo.vn/public_html          │
│ exec mode         │ fork_mode                                │
│ node.js version   │ 16.18.1                                  │
│ node env          │ N/A                                      │
│ watch & reload    │ ✘                                        │
│ unstable restarts │ 0                                        │
│ created at        │ N/A                                      │
└───────────────────┴──────────────────────────────────────────┘
 Divergent env variables from local env
┌────────────────┬────────────────────────────────┐
│ XDG_SESSION_ID │ 2870                           │
│ TERM           │ xterm                          │
│ SSH_CLIENT     │ 59.153.240.148 28488 2222      │
│ OLDPWD         │ /home                          │
│ SSH_TTY        │ /dev/pts/0                     │
│ LS_COLORS      │ rs=0:di=01;34:ln=01;36:mh=00:p │
│ PWD            │ /home/chat.socdo.vn/public_htm │
│ SSH_CONNECTION │ 59.153.240.148 28488 45.32.109 │
└────────────────┴────────────────────────────────┘

 Add your own code metrics: http://bit.ly/code-metrics
 Use `pm2 logs index [--lines 1000]` to display logs
 Use `pm2 env 0` to display environment variables
 Use `pm2 monit` to monitor CPU and Memory usage index
[root@socdo home]# pm2 describe 1
 Describing process with id 1 - name index
┌───────────────────┬──────────────────────────────────────────────────────┐
│ status            │ online                                               │
│ name              │ index                                                │
│ namespace         │ default                                              │
│ version           │ 1.0.0                                                │
│ restarts          │ 15                                                   │
│ uptime            │ 25D                                                  │
│ script path       │ /home/chat.trungtamkcnphutho.vn/public_html/index.js │
│ script args       │ N/A                                                  │
│ error log path    │ /root/.pm2/logs/index-error.log                      │
│ out log path      │ /root/.pm2/logs/index-out.log                        │
│ pid path          │ /root/.pm2/pids/index-1.pid                          │
│ interpreter       │ node                                                 │
│ interpreter args  │ N/A                                                  │
│ script id         │ 1                                                    │
│ exec cwd          │ /home/chat.trungtamkcnphutho.vn/public_html          │
│ exec mode         │ fork_mode                                            │
│ node.js version   │ 16.18.1                                              │
│ node env          │ N/A                                                  │
│ watch & reload    │ ✘                                                    │
│ unstable restarts │ 0                                                    │
│ created at        │ 2025-10-10T08:04:39.754Z                             │
└───────────────────┴──────────────────────────────────────────────────────┘
 Actions available
┌────────────────────────┐
│ km:heapdump            │
│ km:cpu:profiling:start │
│ km:cpu:profiling:stop  │
│ km:heap:sampling:start │
│ km:heap:sampling:stop  │
└────────────────────────┘
 Trigger via: pm2 trigger index <action_name>

 Code metrics value
┌────────────────────────┬───────────────────────┐
│ HTTP                   │ 0.01 req/min          │
│ HTTP P95 Latency       │ 22252.749999999996 ms │
│ HTTP Mean Latency      │ 161 ms                │
│ Used Heap Size         │ 15.18 MiB             │
│ Heap Usage             │ 67.07 %               │
│ Heap Size              │ 22.63 MiB             │
│ Event Loop Latency p95 │ 1.42 ms               │
│ Event Loop Latency     │ 0.58 ms               │
│ Active handles         │ 44                    │
│ Active requests        │ 0                     │
└────────────────────────┴───────────────────────┘
 Divergent env variables from local env
┌────────────────┬────────────────────────────────┐
│ XDG_SESSION_ID │ 822                            │
│ TERM           │ xterm                          │
│ SSH_CLIENT     │ 117.5.225.247 54364 2222       │
│ OLDPWD         │ /home                          │
│ SSH_TTY        │ /dev/pts/0                     │
│ LS_COLORS      │ rs=0:di=01;34:ln=01;36:mh=00:p │
│ PWD            │ /home/chat.trungtamkcnphutho.v │
│ SSH_CONNECTION │ 117.5.225.247 54364 167.179.11 │
└────────────────┴────────────────────────────────┘

 Add your own code metrics: http://bit.ly/code-metrics
 Use `pm2 logs index [--lines 1000]` to display logs
 Use `pm2 env 1` to display environment variables
 Use `pm2 monit` to monitor CPU and Memory usage index
[root@socdo home]# pm2 logs 1 --lines 50
[TAILING] Tailing last 50 lines for [1] process (change the value with --lines option)
/root/.pm2/logs/index-out.log last 50 lines:
/root/.pm2/logs/index-error.log last 50 lines:
1|index    |     at Server.setupListenHandle [as _listen2] (node:net:1463:16)
1|index    |     at listenInCluster (node:net:1511:12)
1|index    |     at Server.listen (node:net:1599:7)
1|index    |     at Object.<anonymous> (/home/chat.socdo.vn/public_html/index.js:16:8)
1|index    |     at Module._compile (node:internal/modules/cjs/loader:1155:14)
1|index    |     at Object.Module._extensions..js (node:internal/modules/cjs/loader:1209:10)
1|index    |     at Module.load (node:internal/modules/cjs/loader:1033:32)
1|index    |     at Function.Module._load (node:internal/modules/cjs/loader:868:12)
1|index    |     at Object.<anonymous> (/usr/local/lib/node_modules/pm2/lib/ProcessContainerFork.js:33:23)
1|index    |     at Module._compile (node:internal/modules/cjs/loader:1155:14) {
1|index    |   code: 'EADDRINUSE',
1|index    |   errno: -98,
1|index    |   syscall: 'listen',
1|index    |   address: '::',
1|index    |   port: 3000
1|index    | }
1|index    | Error: listen EADDRINUSE: address already in use :::3000
1|index    |     at Server.setupListenHandle [as _listen2] (node:net:1463:16)
1|index    |     at listenInCluster (node:net:1511:12)
1|index    |     at Server.listen (node:net:1599:7)
1|index    |     at Object.<anonymous> (/home/chat.socdo.vn/public_html/index.js:16:8)
1|index    |     at Module._compile (node:internal/modules/cjs/loader:1155:14)
1|index    |     at Object.Module._extensions..js (node:internal/modules/cjs/loader:1209:10)
1|index    |     at Module.load (node:internal/modules/cjs/loader:1033:32)
1|index    |     at Function.Module._load (node:internal/modules/cjs/loader:868:12)
1|index    |     at Object.<anonymous> (/usr/local/lib/node_modules/pm2/lib/ProcessContainerFork.js:33:23)
1|index    |     at Module._compile (node:internal/modules/cjs/loader:1155:14) {
1|index    |   code: 'EADDRINUSE',
1|index    |   errno: -98,
1|index    |   syscall: 'listen',
1|index    |   address: '::',
1|index    |   port: 3000
1|index    | }
1|index    | Error: listen EADDRINUSE: address already in use :::3000
1|index    |     at Server.setupListenHandle [as _listen2] (node:net:1463:16)
1|index    |     at listenInCluster (node:net:1511:12)
1|index    |     at Server.listen (node:net:1599:7)
1|index    |     at Object.<anonymous> (/home/chat.socdo.vn/public_html/index.js:16:8)
1|index    |     at Module._compile (node:internal/modules/cjs/loader:1155:14)
1|index    |     at Object.Module._extensions..js (node:internal/modules/cjs/loader:1209:10)
1|index    |     at Module.load (node:internal/modules/cjs/loader:1033:32)
1|index    |     at Function.Module._load (node:internal/modules/cjs/loader:868:12)
1|index    |     at Object.<anonymous> (/usr/local/lib/node_modules/pm2/lib/ProcessContainerFork.js:33:23)
1|index    |     at Module._compile (node:internal/modules/cjs/loader:1155:14) {
1|index    |   code: 'EADDRINUSE',
1|index    |   errno: -98,
1|index    |   syscall: 'listen',
1|index    |   address: '::',
1|index    |   port: 3000
1|index    | }