// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

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
			showOn: "=",
			question: "=",
			user: "=" 
		},
		templateUrl: "question-discussion.html",
		link: function(scope){
			console.log(scope.user);
		}
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
		return $http.post("/api/questions/"+question.id+"/reply", { reply: question.reply })
	}
	q.getReplies = function(question){
		return $http.get("/api/questions/"+question.id+"/get/replies");
	}

	return q;
});

app.factory("users", function($http){
	var u = {};

	u.getCurrent = function(){
		return $http.get("/api/user/current");
	}

	return u;
})

app.controller('Main', ['$scope', '$timeout', '$mdSidenav', '$mdDialog', 'category', 'questions', 'users', function($scope, $timeout, $mdSidenav, $mdDialog, category, questions, users){
	var main = this;
	main.show = {
		list: true,
		question: false,
		ask: false,
		addCat: false
	}
	$scope.acct = "Account";
	$scope.toggleSidenav = function(menuId) {
		$mdSidenav(menuId).toggle();
	};
	main.placeCategories = function(){
		category.getAll().success(function(resp){
			if(resp.status == 0)
				main.categories = resp.categories;
		});
	}
	main.getQuestions = function(){
		main.show.list = true;
		main.show.question = false;
		questions.get(main.currentCategory, main.currentStatus).success(function(resp){
			if(resp.status == 0)
				main.questions = resp.questions;
		});
	}
	main.getCurrentUser = function(){
		users.getCurrent().success(function(resp){
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
			templateUrl: 'dialog.html',
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
			templateUrl: 'new-user-dialog.html',
			targetEvent: ev
		})
		.then(function(answer) {
			main.getQuestions();
		}, function() {
			$scope.alert = 'You cancelled the dialog.';
		});
	}
	main.setStatus = function(status){
		main.currentStatus = status;
		main.getQuestions();
	}
	main.setCategory = function(category){
		main.currentCategory = category;
		main.getQuestions();
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
		$timeout(function(){
			main.show.list = false;
			main.show.question = true;
			questions.getCurrent(q).success(function(resp){
				if(resp.status == 0){
					main.current = resp.question;
					console.log(main.current);
				}
			});
		}, 200);
	}
	main.currentStatus = 'unanswered';
	main.currentCategory = 'my questions';
	main.placeCategories();
	main.getQuestions();
	main.getCurrentUser();
}]);

app.controller("Question", function($scope,$timeout,questions){
	var q = this;
	q.reply = function(question,reply){
		var nq = { id: question.id, reply: reply }
		q.replyBody = null;
		questions.reply(nq).success(function(resp){
			if(resp.status == 0)
				q.getReplies(question);
		});
	}
	q.getReplies = function(question){
		$scope.$watch("question", function(){
			if($scope.question){
				questions.getReplies($scope.question).success(function(resp){
					if(resp.status == 0)
						q.replies = resp.replies;
				});
			}
	    });
	}
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
});
