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
var io = require("socket.io")(server);
server.listen(process.env.PORT ||3000);
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
/*		var chon_thongbao = setInterval(function(){
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
/*	setInterval(function(){
		io.sockets.emit("server_send_online");
	},120e3);*/
});
app.get("/", function(req,res){
	res.render('trangchu');
});
