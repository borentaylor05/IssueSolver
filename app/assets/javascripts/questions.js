// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

var catJoin = function(str){
	return str.split(" ").join("-")
}

var app = angular.module("App", ['ngMaterial']);

app.config(function($mdThemingProvider) {
  $mdThemingProvider.theme('default')
    .primaryPalette('light-green')
    .accentPalette('lime');
  });

app.directive("questionDiscussion", function(){
	return {
		restrict: "E",
		scope: {
			user: "="
		},
		templateUrl: "/question-discussion.html"
	}
});

app.directive("onHover", function(){
	return function(scope, el, attr){
		el.on("mouseenter", function(){
			el.removeClass("hide");
		});
		el.on("mouseleave", function(){
			el.addClass("hide");
		});
	}
});

app.factory("category", function($http){
	var cat = {};

	cat.getAll = function(){
		return $http.get("/api/categories");	
	}
	cat.getDB = function(){
		return $http.get("/api/categories?dbonly=true");	
	}
	cat.create = function(category){
		return $http.post("/api/categories/create", category);
	}

	return cat;
});

app.factory("questions", function($http){
	var q = {};

	q.get = function(category, status){
		category = category.toLowerCase().split(" ").join("-");
		return $http.get("/api/questions/"+category+"/"+status);	
	}
	q.getCurrent = function(question){
		return $http.get("/api/questions/"+question.id);
	}
	q.create = function(question){
		return $http.post("/api/questions", question);
	}
	q.reply = function(question){
		console.log(question);
		return $http.post("/api/questions/"+question.id+"/reply", { reply: question.reply })
	}
	q.getReplies = function(question_id){
		return $http.get("/api/questions/"+question_id+"/get/replies");
	}
	q.answer = function(question, reply){
		return $http.post("/api/questions/"+question.id+"/answer", { reply: reply });
	}

	return q;
});

app.factory("users", function($http){
	var u = {};

	u.getCurrent = function(){
		return $http.get("/api/user/current");
	}
	u.create = function(user){
		return $http.post("/api/users", user);
	}

	return u;
})

app.controller('Main', ['$scope', '$timeout', '$interval', '$mdSidenav', '$mdDialog', 'category', 'questions', 'users', function($scope, $timeout, $interval, $mdSidenav, $mdDialog, category, questions, users){
	var main = this;
	main.show = {
		list: true,
		question: false,
		ask: false,
		addCat: false
	};
	main.preventStupid = false;
	$scope.acct = "Account";
	$scope.toggleSidenav = function(menuId) {
		$mdSidenav(menuId).toggle();
	};
	main.placeCategories = function(){
		category.getAll().success(function(resp){
			console.log(resp);
			if(resp.status == 0)
				main.categories = resp.categories;
		});
	}
	main.getQuestions = function(){
		if(!main.currentCategory || !main.currentStatus){
			var parts = window.location.hash.split(":");
			main.currentCategory = parts[0];
			main.currentStatus = parts[1];
		}
		main.currentCategory = main.currentCategory.split("-").join(" ");
		main.currentStatus = main.currentStatus.split("-").join(" ");
		questions.get(main.currentCategory, main.currentStatus).success(function(resp){
			console.log(resp);
			if(resp.status == 0){
				main.show.list = true;
				main.show.question = false;
				main.questions = resp.questions;
				main.currentUser = resp.current;
			}				
		});
	}
	main.getCurrentUser = function(){
		users.getCurrent().success(function(resp){
			console.log("USER", resp)
			if(status == 0)
				main.currentUser = resp.user
		});
	}
	main.isActive = function(cat){
		if(cat == main.currentCategory)
			return "active";
	}
	main.askQuestion = function(ev){
		$mdDialog.show({
			controller: "AskCtrl as ask",
			templateUrl: '/dialog.html',
			targetEvent: ev
		})
		.then(function(answer) {
			main.getQuestions();
		}, function() {
			$scope.alert = 'You cancelled the dialog.';
		});
	}
	main.newUser = function(ev){
		$mdDialog.show({
			controller: "NewUserCtrl as nu",
			templateUrl: '/new-user-dialog.html',
			targetEvent: ev
		})
		.then(function(answer) {
			main.getQuestions();
		}, function() {
			$scope.alert = 'You cancelled the dialog.';
		});
	}
	main.setStatus = function(status){
		if(!main.preventStupid){
			main.currentStatus = status;
			if(!main.currentCategory)
				main.currentCategory = "my-questions";
			if(window.location.pathname == "/"){
				window.location.hash = catJoin(main.currentCategory)+":"+catJoin(main.currentStatus);
				main.getQuestions();
			}
			else{
				window.location.href = "/#"+catJoin(main.currentCategory)+":"+catJoin(main.currentStatus);
			}		
		}
	}
	main.setCategory = function(category){
		main.currentCategory = category;
		if(!main.currentStatus)
			main.currentStatus = 'unanswered';
		if(window.location.pathname == "/"){
			window.location.hash = catJoin(main.currentCategory)+":"+catJoin(main.currentStatus);
			main.getQuestions();
		}
		else{
			window.location.href = "/#"+catJoin(main.currentCategory)+":"+catJoin(main.currentStatus);
		}				
	}
	main.createCategory = function(cat){
		category.create(cat).success(function(resp){
			if(resp.status == 0){
				main.placeCategories();
				main.show.addCat = false;
			}				
		});
	}
	main.openCat = function(){
		main.show.addCat = !main.show.addCat;
	}
	main.go = function(q){
		main.preventStupid = true;
		$timeout(function(){
		//	main.show.list = false;
		//	main.show.question = true;
			window.location.href = "/questions/"+q.id;
			// questions.getCurrent(q).success(function(resp){
			// 	if(resp.status == 0){
			// 		main.current = resp.question;
			// 		main.preventStupid = false;
			// 		$timeout(function(){
			// 			main.getCurrentUser();
			// 		}, 1000);
			// 	}
			// });
		}, 200);
	}
	main.chooseAnswer = function(reply){
		questions.answer(reply).success(function(resp){
			console.log(resp);
		});
	}
	main.refresh = function(){
		if(main.show.list){
			main.getQuestions();
		}
		else if(main.show.question){
			main.go(main.current);
		}
	}
	if(window.location.pathname == "/"){
		main.currentStatus = 'unanswered';
		main.currentCategory = 'my questions';
		main.placeCategories();
		main.getQuestions();
	}
	main.placeCategories();
	main.getCurrentUser();
	// $interval(function(){
	// 	main.refresh();
	// }, 30000);
}]);

app.controller("Question", function($scope,$timeout,questions, users){
	var q = this;
	q.currentReply = {};
	q.current = {};
	q.reply = function(question,reply){
		var nq = { id: question.id, reply: reply }
		q.replyBody = null;
		questions.reply(nq).success(function(resp){
			if(resp.status == 0)
				q.getReplies(question.id);
		});
	}
	q.getReplies = function(question_id){	
		questions.getReplies(question_id).success(function(resp){
			if(resp.status == 0){
				q.replies = resp.replies;
				q.current = resp.question;
				$timeout(function(){
					q.getCurrentUser();
				}, 500);
			}					
		});
	}
	q.answer = function(reply){
		questions.answer(q.current, reply).success(function(resp){
			if(resp.status == 0){
				q.current = resp.question;
				q.getReplies(q.current.id);				
			}				
		});	
	}
	q.getCurrentUser = function(){
		users.getCurrent().success(function(resp){
			if(status == 0){
				$scope.user = resp.user
				$scope.$parent.$parent.main.currentUser = resp.user;
			}				
		});
	}
	q.setActive = function(r){
		q.currentReply = r;
	}
	q.isActive = function(r){
		if(r == q.currentReply)
			return true;
		else
			return false;
	}
	q.showCheck = function(user){
		if(!q.current.answered && ( q.current.user == user || user.admin || user.mentor || user.l2 ))
			return true;
		else
			return false;
	}
	var parts = window.location.pathname.split("/");
	q.getReplies(parts[parts.length - 1]);	
});


app.controller("AskCtrl", function($scope, $mdDialog, category, questions){
	var ask = this;
	$scope.hide = function() {
		$mdDialog.hide();
	};
	$scope.cancel = function() {
		$mdDialog.cancel();
	};
	$scope.answer = function(answer) {
		$mdDialog.hide(answer);
	};
	ask.getCategories = function(){
		category.getDB().success(function(resp){
			if(resp.status == 0){
				ask.categories = resp.categories;
			}
		});
	}
	ask.askQuestion = function(question){
		$mdDialog.hide();
		questions.create(question).success(function(resp){
			console.log(resp);
		});
	}
});

app.controller("NewUserCtrl", function($scope, $mdDialog, users){
	var nu = this;
	$scope.hide = function() {
		$mdDialog.hide();
	};
	$scope.cancel = function() {
		$mdDialog.cancel();
	};
	$scope.answer = function(answer) {
		$mdDialog.hide(answer);
	};
	nu.createUser = function(user){
		users.create(user).success(function(resp){
			console.log(resp);
		});
	}
});
