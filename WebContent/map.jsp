<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="initial-scale=1.0, user-scalable=no">
    <meta charset="utf-8">
    <title>Trip Planner</title>
    <style>
      html, body, #map-canvas {
        height: 97%;
        width: 100%;
        margin: 0px;
        padding: 0px
      }
      #panel {
        position: absolute;
        top: 5px;
        left: 50%;
        margin-left: -180px;
        z-index: 5;
        background-color: #fff;
        padding: 5px;
        border: 1px solid #999;
      }
      #start {
        width: 95%;
      }
      #end {
        width: 95%;
      }
      #likeabutton {
	    appearance: button;
	    -moz-appearance: button;
	    -webkit-appearance: button;
	    text-decoration: none; font: menu; color: ButtonText;
	    display: inline-block; padding: 2px 8px;
	  }
	  #hidden1 {
	   display: none;
	  }
	  #hidden2 {
       display: none;
      }
    </style>
    <style>
      #directions-panel {
        height: 100%;
        float: right;
        width: 100%;
        overflow: auto;
      }

      #map-canvas {
        margin-right: 400px;
      }

      #control {
        background: #fff;
        padding: 5px;
        font-size: 14px;
        font-family: Arial;
        border: 1px solid #ccc;
        box-shadow: 0 2px 2px rgba(33, 33, 33, 0.4);
        display: none;
        width: 80%;
      }

      @media print {
        #map-canvas {
          height: 500px;
          margin: 0;
        }

        #directions-panel {
          float: none;
          width: auto;
        }
      }
    </style>
    <script
    src="//google-maps-utility-library-v3.googlecode.com/svn/trunk/geolocationmarker/src/geolocationmarker-compiled.js"></script>
    <script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyB88KAvqVW035HB3HUvWhh-T379_0702S0&sensor=true&libraries=places&language=en"></script>
    <script>
var directionsDisplay;
var directionsService = new google.maps.DirectionsService();
var current;
var godown = true;
var map;

function showCurrentLocation(map) {
  var myloc = new google.maps.Marker({
    clickable: false,
    icon: new google.maps.MarkerImage('//maps.gstatic.com/mapfiles/mobile/mobileimgs2.png',
                                                    new google.maps.Size(22,22),
                                                    new google.maps.Point(0,18),
                                                    new google.maps.Point(11,11)),
    shadow: null,
    zIndex: 999,
    map: map // your google.maps.Map object
  });

  if (navigator.geolocation) navigator.geolocation.getCurrentPosition(function(pos) {
    current = new google.maps.LatLng(pos.coords.latitude, pos.coords.longitude);
    myloc.setPosition(current);
    map.setCenter(current);
  }, function(error) {
    allert(error);
  });
}

function initialize() {
  directionsDisplay = new google.maps.DirectionsRenderer();
  var mapOptions = {
    zoom: 15,
    center: new google.maps.LatLng(-34.397, 150.644),
    mapTypeControl: false,
    streetViewControl: false
  };
  map = new google.maps.Map(document.getElementById('map-canvas'),
      mapOptions);
  directionsDisplay.setMap(map);
  directionsDisplay.setPanel(document.getElementById('directions-panel'));

  var control = document.getElementById('control');
  control.style.display = 'block';
  map.controls[google.maps.ControlPosition.TOP_CENTER].push(control);
  showCurrentLocation(map);


  var start = /** @type {HTMLInputElement} */(
      document.getElementById('start'));
  var end = /** @type {HTMLInputElement} */(
      document.getElementById('end'));
  
  var options = {
		  bounds: current,
		  types: ['establishment']
		};

  var autocompleteStart = new google.maps.places.Autocomplete(start, options);
  var autocompleteEnd = new google.maps.places.Autocomplete(end, options);
  
  google.maps.event.addListener(autocompleteStart, 'place_changed', function() {
	  calcRoute();
	  });
  google.maps.event.addListener(autocompleteEnd, 'place_changed', function() {
	  calcRoute();
    });
}

function calcRoute() {
  var start = document.getElementById('start').value;
  var end = document.getElementById('end').value;
  var timeType = document.getElementById('timeType').value;
  var time = document.getElementById('time').value;

  if (start == null || start == "") {
    start = current;
  }
  if (end == null || end == "") {
    end = current;
  }
  
  if (time == null || time == "") {
	  var request = {
		        origin: start,
		        destination: end,
		        travelMode: google.maps.TravelMode.TRANSIT,
		        provideRouteAlternatives: true,
		      };
	  directionsService.route(request, function(response, status) {
		    if (status == google.maps.DirectionsStatus.OK) {
		      directionsDisplay.setDirections(response);
		    }
		  });
	  return;
  }

  var request;

  switch(timeType) {
    case "leave_now":
      request = {
        origin: start,
        destination: end,
        travelMode: google.maps.TravelMode.TRANSIT,
        provideRouteAlternatives: true,
      };
      break;
    case "departure_at":
      var d = new Date(time);
      d.setTime( d.getTime() + d.getTimezoneOffset()*60*1000 );
      request = {
        origin: start,
        destination: end,
        travelMode: google.maps.TravelMode.TRANSIT,
        provideRouteAlternatives: true,
        transitOptions: {
          departureTime: d
        },
      };
      break;
    case "arrive_by":
      var d = new Date(time);
      d.setTime( d.getTime() + d.getTimezoneOffset()*60*1000 );
      request = {
        origin: start,
        destination: end,
        travelMode: google.maps.TravelMode.TRANSIT,
        provideRouteAlternatives: true,
        transitOptions: {
          arrivalTime: d
       },
      };
      break;
  }

  directionsService.route(request, function(response, status) {
    if (status == google.maps.DirectionsStatus.OK) {
      directionsDisplay.setDirections(response);
      addBus();
    }
  });
}

google.maps.event.addDomListener(window, 'load', initialize);

function showSpan() {
	document.getElementById('hidden1').style.display = "inline";
	document.getElementById('hidden2').style.display = "inline";
}

function addBus() {
	var image = {
		    url: "${pageContext.request.contextPath}/images/bus_icon.gif",
		    scaledSize: new google.maps.Size(25, 25)
		  };
	
	  var contentString = '<div id="content">'+
	      '<div id="siteNotice">'+
	      '</div>'+
	      '<h4>61D: To Downtown Pittsburgh</h4>'+
	      '<div id="bodyContent">'+
	      'Distance Travel: 0.5 miles <br>'+
	      'Arrival Time: 3 min'+
	      '</div>'+
	      '</div>';
	  
	var marker1 = new google.maps.Marker({
	    position: new google.maps.LatLng(40.4443667,-79.9412597),
	    map: map,
        icon:image 
	});
	
    var infowindow = new google.maps.InfoWindow({
        content: contentString
    });
    
	google.maps.event.addListener(marker1, 'click', function() {
		map.panTo(marker1.getPosition());
        infowindow.open(map,marker1);
      });
	
	var marker2 = new google.maps.Marker({
        position: new google.maps.LatLng(40.4467644,-79.9423331),
        map: map,
        icon: image
    });
	
	google.maps.event.addListener(marker2, 'click', function() {
		map.panTo(marker2.getPosition());
		infowindow.open(map,marker2);
      });
	
	var marker3 = new google.maps.Marker({
        position: new google.maps.LatLng(40.438058,-79.930937),
        map: map,
        icon: image
    });
	
	
	google.maps.event.addListener(marker3, 'click', function() {
		map.panTo(marker3.getPosition());
		infowindow.open(map,marker3);
      });
	
	var marker4 = new google.maps.Marker({
        position: new google.maps.LatLng(40.447987,-79.940094),
        map: map,
        icon: image
    });
	
	google.maps.event.addListener(marker4, 'click', function() {
		map.panTo(marker4.getPosition());
		infowindow.open(map,marker4);
      });
}

    </script>
  <script src="//cdnjs.cloudflare.com/ajax/libs/annyang/1.1.0/annyang.min.js"></script>
  <script src="//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>

  <script>
    $.fn.setNow = function (onlyBlank) {
	  var now = new Date($.now())
	    , year
	    , month
	    , date
	    , hours
	    , minutes
	    , formattedDateTime
	    ;
	  
	  year = now.getFullYear();
	  month = now.getMonth().toString().length === 1 ? '0' + (now.getMonth() + 1).toString() : now.getMonth() + 1;
	  date = now.getDate().toString().length === 1 ? '0' + (now.getDate()).toString() : now.getDate();
	  hours = now.getHours().toString().length === 1 ? '0' + now.getHours().toString() : now.getHours();
	  minutes = now.getMinutes().toString().length === 1 ? '0' + now.getMinutes().toString() : now.getMinutes();
	  
	  formattedDateTime = year + '-' + month + '-' + date + 'T' + hours + ':' + minutes;
	 
	  if ( onlyBlank === true && $(this).val() ) {
	    return this;
	  }
	  
	  $(this).val(formattedDateTime);
	  
	  return this;
	}
  
    $(document).ready(function() {
      $("#likeabutton").on("click", function( e ) {
    	  
          e.preventDefault();
          if (godown) {
        	  $("body, html").animate({ 
                  scrollTop: $( $(this).attr('href') ).offset().top 
              }, 600);
        	  $( this ).text("View Map");
          } else {
        	  $("body, html").animate({ 
                  scrollTop: 0 
              }, 600);
        	  $( this ).text("Routes Detail");
          }
          godown = !godown;

      });
      
      $('#time').setNow();
    });
    
    $('#end').keyup(function() {
    	alert($(this).val());
    	if ($(this).val() == "from") {
    		$(this).text("");
    	}
        
    });
  </script>
  
  <script src="//cdnjs.cloudflare.com/ajax/libs/annyang/1.1.0/annyang.min.js"></script>
	<script>
	if (annyang) {
	  // Let's define our first command. First the text we expect, and then the function it should call
	  var commands = {
	    'hello' : function() {
	    	alert('hello');
	    },
	    'to *b': function(b) {
	    	  var request = {
	    	        origin: current,
	    	        destination: 'university of pittsburgh',
	    	        travelMode: google.maps.TravelMode.TRANSIT,
	    	        provideRouteAlternatives: true,
	    	      };
	    	  directionsService.route(request, function(response, status) {
	    		    if (status == google.maps.DirectionsStatus.OK) {
	    		      directionsDisplay.setDirections(response);
	    		      addBus();
	    		    }
	    		  });
	    },
	    'from *a to *b': function(a, b) {
              var request = {
                    origin: a,
                    destination: b,
                    travelMode: google.maps.TravelMode.TRANSIT,
                    provideRouteAlternatives: true,
                  };
              directionsService.route(request, function(response, status) {
                    if (status == google.maps.DirectionsStatus.OK) {
                      directionsDisplay.setDirections(response);
                      addBus();
                    }
                  });
        }
	  };
	  
	  // OPTIONAL: activate debug mode for detailed logging in the console
	  annyang.debug();
	  // Add our commands to annyang
	  annyang.addCommands(commands);
	
	  // OPTIONAL: Set a language for speech recognition (defaults to English)
	  annyang.setLanguage('en');
	  
	  // Start listening. You can call this here, or attach this call to an event, button, etc.
	  annyang.start();
	}
	</script>

  </head>
  <body>
    <div id="control">
      <form id="search">
        <span id="hidden1">
	        <input id="start" placeholder="From current location">
	        <br>
        </span>
      	<input id="end" placeholder="To" onclick="showSpan();">
      	<span id="hidden2">
	        <br>
	        <select id="timeType" onchange="calcRoute();">
	          <option value="leave_now" selected>Leave now</option>
	          <option value="departure_at">Depart at</option>
	          <option value="arrive_by">Arrive by</option>
	        </select>
	        <input type="datetime-local" id="time" onchange="calcRoute();" style="width: 180px;">
      	</span>
      </form>
    </div>
    <div id="map-canvas"></div>
    <div>
	    
    </div>
    <br>
    <a id="likeabutton" href="#directions-panel">Routes Detail</a>
    <div id="directions-panel">
    </div>
  </body>
</html>