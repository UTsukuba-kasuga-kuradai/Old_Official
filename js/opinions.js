(function() {
  var opinions;

  opinions = function(page) {
    var url;
    if (page == null) {
      page = 0;
    }
    url = "http://www.stb.tsukuba.ac.jp/~kasuga-campus/v1/opinions.php";
    if (page) {
      url += "?page=" + page;
    }
    return $.ajax({
      type: 'GET',
      url: url,
      dataType: 'json',
      success: function(data) {
        var i, json, key, val, _box, _dom, _i, _img, _j, _label, _len, _ref, _ref1, _results;
        json = JSON.parse(data);
        console.log(json);
        $(".opinions").empty();
        _ref = json.item;
        for (key = _i = 0, _len = _ref.length; _i < _len; key = ++_i) {
          val = _ref[key];
          console.log(key);
          console.log(val);
          _label = $("<span>", {
            "class": "opinion-label",
            text: val.label
          });
          _img = $("<img>", {
            src: "http://www.stb.tsukuba.ac.jp/~kasuga-campus/v1/image/" + val.file_name
          });
          _box = $('<div>', {
            "class": "opinion-item"
          }).append(_label, _img);
          _dom = $('<div>', {
            "class": "opinion-box col-4"
          }).append(_box);
          $('.opinions').append(_dom);
        }
        $(".opinion-menus").empty();
        _results = [];
        for (i = _j = 0, _ref1 = json.info.count / 16; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
          _dom = $('<div>', {
            "class": "opinion-menu",
            text: i,
            "data-page": i
          }).click(function() {
            return opinions($(this).data("page"));
          });
          _results.push($('.opinion-menus').append(_dom));
        }
        return _results;
      },
      error: function(e) {
        var _dom;
        _dom = $('<div>', {
          "class": "opinion-error col-12",
          text: "データの取得に失敗しました"
        });
        return $('.opinions').prepend(_dom);
      }
    });
  };

  $(function() {
    return opinions();
  });

}).call(this);
