/* "PyukiWiki" version 0.1.7 $$ */
/* $Id: common.ja.js,v 1.99 2007/07/15 07:40:09 papu Exp $ */
/* Code=EUC-JP */

var d=document;
var ie=d.selection ? 1 : 0;
var moz=(d.getSelection && !window.opera) ? 1 : 0;

/* for antispam.inc.cgi */
function addec_link(ad) {
	var dif = cs.indexOf(ad.charAt(0))*cs.length+cs.indexOf(ad.charAt(1));
	for(var dec="",i=2;i<ad.length;i+=2) {
		var c0=cs.indexOf(ad.charAt(i)), c=c0*cs.length+cs.indexOf(ad.charAt(i+1))-dif;
		dec=dec+String.fromCharCode(c);
	}
	if(confirm( '送信先を\n>> '+dec+'\nとして新規にメールを作成します.')) {
		location=dec;
	}
}

function addec_text(ad) {
	var dif=cs.indexOf(ad.charAt(0))*cs.length+cs.indexOf(ad.charAt(1));
	for(var dec="",i=2;i<ad.length;i+=2) {
		var c0=cs.indexOf(ad.charAt(i)), c=c0*cs.length+cs.indexOf(ad.charAt(i+1))-dif;
		dec=dec+String.fromCharCode(c);
	}
	document.write(dec);
}

function openURI(a, frame){
	window.open(a, frame);
	return false;
}

/* for ref.inc.pl */
/* from http://martin.p2b.jp/index.php?UID=1115484023 */

function getClientWidth(){
	if(self.innerWidth){
		return self.innerWidth;
	} else if(d.documentElement && d.documentElement.clientWidth){
		return d.documentElement.clientWidth;
	} else if(d.body){
		return d.body.clientWidth;
	}
}

function getClientHeight(){
	if(self.innerHeight){
		return self.innerHeight;
	} else if(d.documentElement && d.documentElement.clientHeight){
		return d.documentElement.clientHeight;
	} else if(d.body){
		return d.body.clientHeight;
	}
}

function getDocHeight(){
	var h;
	if(d.documentElement && d.body){
		h = Math.max(
		d.documentElement.scrollHeight,d.documentElement.offsetHeight,d.body.scrollHeight
	);
	} else h = d.body.scrollHeight;
	return (arguments.length==1) ? h + 'px' : h;
}

function getScrollY(){
	if(typeof window.pageYOffset != "undefined"){
		return window.pageYOffset;
	} else if(d.body && typeof d.body.scrollTop != "undefined"){
		return d.body.scrollTop;
	} else if(d.documentElement && typeof d.documentElement.scrollTop != "undefined"){
		return d.documentElement.scrollTop;
	}
	return 0;
}

var imgPop = null;

imagePop = function (e, path, w, h){
	if(imgPop==null){
		imgPop = d.createElement("IMG");
		imgPop.src = path;
		with (imgPop.style){
			position = "absolute";
			left = Math.round((getClientWidth()-w) / 2) + "px";
			top = Math.round((getClientHeight()-h) / 2 + getScrollY()) + "px";
			margin = "0";
			zIndex = 1000;
			border = "4px groove Teal";
			display = "none";
		}
		d.body.appendChild(imgPop);
		if(imgPop.complete){
			imgPop.style.display = "block";
		} else window.status = "Loading image...";
		imgPop.onload = function(){imgPop.style.display="block"; window.status="";}
		imgPop.onclick = function(){d.body.removeChild(imgPop);imgPop=null;}
		imgPop.title = "マウスクリックで閉じます";
	}
}

/* from http://martin.p2b.jp/index.php?date=20050201 */
hackFirefoxToolTip = function(e){
	var aa=d.getElementsByTagName('A');
	var tT=d.createElement('DIV');
	var sd=d.createElement('DIV');

	with(tT.style) {
		position='absolute';
		backgroundColor='ivory';
		border='1px solid #333';
		padding='1px 3px 1px 3px';
		font='500 11px arial';
		zIndex=10000;
		top="-100px";
	}
	with (sd.style) {
		position='absolute';
		MozOpacity=0.3;
		MozBorderRadius='3px';
		background='#000';
		zIndex=tT.style.zIndex - 1;
	}
	for(i=0,l=aa.length;i<l;i++){
		if(aa[i].getAttribute('title') != null || aa[i].getAttribute('alt') != null){
			aa[i].onmouseover=function(e){
				var _title=this.getAttribute('title')!=null ? this.getAttribute('title') : this.getAttribute('alt');
				this.setAttribute('title', '');
				_title=_title.replace(/[\r\n]+/g,'<br/>').replace(/\s/g,'&nbsp;');
				if(_title=='') return;
				tT.style.left=20+e.pageX+'px';
				tT.style.top=10+e.pageY+'px';
				tT.innerHTML=_title;
				with(sd.style){
					width=tT.offsetWidth-2+'px';
					height=tT.offsetHeight-2+'px';
					left=parseInt(tT.style.left)+5+'px';
					top=parseInt(tT.style.top)+5+'px';
				}
			}
			aa[i].onmouseout=function(){
				this.setAttribute('title', tT.innerHTML.replace(/<br\/>/g,'&#13;&#10;').replace(/&nbsp;/g,' '));
				tT.style.top='-1000px';
				sd.style.top='-1000px';
				tT.innerHTML='';
			}
		}
	}
	d.body.appendChild(sd);
	d.body.appendChild(tT);
}

window.onload = function(){
	if(moz) hackFirefoxToolTip();
}
