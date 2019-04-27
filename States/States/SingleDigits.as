/**
 * SPACEMATH - AUTHORS: 404 NOT FOUND
 * Class that generates the single digits plus and minus game.
 */

package States
{
	//imports from flash
	import flash.media.Sound;
	import flash.net.URLRequest;
	//imports from our classes
	import Core.Assets;
	import Core.Game;
	import Core.SpaceMath;
	import Interfaces.IState;
	import Objects.Background;
	import Objects.Mouse;
	//imports from starling
	import starling.display.Button;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextFormat;
	
	public class SingleDigits extends Sprite implements IState
	{
		//INSTANCE VARIABLES
		private var game:Game;
		private var background:Background;
		private var rocket:Mouse;
		private var play:Button;
		private var add:Button;
		private var subtract:Button;
		private var progress:Button;
		private var planet:Button;
		private var buttonText:TextFormat;
		private var problems:Array;
		private var answers:Array;
		private var problem:String;
		public static var correctCount:int = 0;
		public static var incorrectCount:int = 0;
		private var count:int = 0;
		private var probNum:int = 0;
		private var updateCount:int = 0;
		
		/**
		 * Constructor for SingleDigits. Adds the game screen to the stage, calls init() and getProblemSet()
		 * to generate problems. 
		 */
		public function SingleDigits(game:Game)
		{
			this.game = game;
			addEventListener(Event.ADDED_TO_STAGE, init);
			problems = []; //initialize problem set
			answers = []; //intialize answers set (+ or -)
			getProblemSet();
			problem  = problems[probNum]; //start game with the first generated problem
			
		}
		
		/**
		 * Method to initialize the game. Adds the star background and all buttons and images. 
		 */
		private function init(event:Event):void
		{
			background = new Background();
			addChild(background);
			
			correctCount = problems.length;
			incorrectCount = 0;
			
			//progress planet
			planet = new Button(Assets.ta.getTexture("planetpng"));
			planet.height = 125;
			planet.width = 200;
			planet.x = background.width - 150;
			planet.y = 620;
			addChild(planet);
			
			//progress button
			progress = new Button(Assets.ta.getTexture("rocket"));
			progress.height = 100;
			progress.width = 100;
			progress.x = -20;
			progress.y = 650;
			addChild(progress);
			
			//play button
			play = new Button(Assets.ta.getTexture("buttonpng"), problem);
			play.addEventListener(Event.TRIGGERED, sendHome);
			play.height = 400;
			play.width = 460;
			play.x = 40;
			play.y = 150;
			play.textFormat.setTo("PT Sans Caption", 80, 0xffffff);
			addChild(play);
			
			//addition button
			add = new Button(Assets.ta.getTexture("addition"));
			add.addEventListener(Event.TRIGGERED, onAdd);
			add.height = 150;
			add.width = 150;
			add.x = 520;
			add.y = 175;
			addChild(add);
			
			//subtraction button
			subtract = new Button(Assets.ta.getTexture("subtract"));
			subtract.addEventListener(Event.TRIGGERED, onSubtract);
			subtract.height = 150;
			subtract.width = 150;
			subtract.x = 520;
			subtract.y = 375;
			addChild(subtract);
		}
		
		/**
		 * Function the listens when the subtract button is clicked. Check with correct answer. 
		 */
		private function onSubtract(event:Event): void 
		{
			var index:int = problems.indexOf(problem);
			if (answers[index] == "-") {
				correctAns(index);
			} else {
				incorrectAns(index);	
			}
		}
		
		/**
		 * Function the listens when the subtract button is clicked. Check with correct answer. 
		 */
		private function onAdd(event:Event): void 
		{
			var index:int = problems.indexOf(problem);
			if (answers[index] == "+") {
				correctAns(index);
			} else {
				incorrectAns(index);	
			}
		}
		
		/**
		 * Functions that gets the player's final score (percent accurate).
		 */
		public static function getScore(): Number
		{
			var score:Number = correctCount - (0.5 * incorrectCount); //problems[] array length - 0.5 per incorrect click
			score = score * 10;
			
			return score
		}
		
		/**
		 * Function for a correct answer.
		 */
		public function correctAns(index:int): void {
			count = 0;
			probNum++;
			if (probNum < problems.length) {
				problem = problems[probNum];
				play.visible = false;
				//generates new play button with next problem
				play = new Button(Assets.ta.getTexture("buttonpng"), problem);
				play.addEventListener(Event.TRIGGERED, sendHome);
				play.height = 400;
				play.width = 460;
				play.x = 40;
				play.y = 150;
				play.textFormat.setTo("PT Sans Caption", 80, 0xffffff);
				addChild(play);
				var yesSound:Sound = new Sound();
				yesSound.load(new URLRequest("simpsons_yes_man.mp3"));
				yesSound.play();
				progress.x += (background.width/problems.length) - 10;
			} else { //game over (all problems answered)
				var clap:Sound = new Sound();
				clap.load(new URLRequest("clap.mp3"));
				clap.play();
				game.changeState(Game.SINGLE_GAME_OVER);
				progress.removeFromParent(true);
			}
		}
		
		/**
		 * Function for a correct answer.
		 */
		public function incorrectAns(index:int): void {
			if (count == 0) {
				incorrectCount++;
			}
			count++; //counts incorrect tries per problem 
			var noSound:Sound = new Sound();
			noSound.load(new URLRequest("patrick_no.mp3"));
			noSound.play();
			if (count == 2) { //if two incorrect tries, show answer
				incorrectCount++;
				//Generates the correction string
				var str:String;
				var ques:int = problem.indexOf("?");
				var beg:String = problem.substring(0,ques);
				var end:String = problem.substring(ques+1);
				var problem2:String = beg + answers[index] + end;
				//Adds the new button with the correct answer
				str = "The correct answer is: " + answers[index] + "\n\n" + problem2;
				play = new Button(Assets.ta.getTexture("buttonpng"), str);
				play.height = 400;
				play.width = 460;
				play.x = 40;
				play.y = 150;
				play.textFormat.setTo("PT Sans Caption", 70, 0xffffff);
				addChild(play);
			}
		}
		
		/**
		 * Sets the instance variables to new problem and answer sets, currently generates 10 problems/answers. 
		 */
		public function getProblemSet(): void {
			var answer:Array = [];
			var firstNum:Array = [];
			var secNum:Array = [];
			
			for(var i:int = 0; i < 10; i++) { //change i < #, to change # of problems in set
				var first:int = randomRange(1,9);
				firstNum[i] = first;
				var second:int = randomRange(1,9);
				secNum[i] = second;
				
				if (firstNum[i] > secNum[i]) { //subtract them
					answers[i] = "-";
					answer[i] = firstNum[i] - secNum[i];
					problems[i] = String(firstNum[i]) + " ? " + String(secNum[i]) + " = " + String(answer[i]);
					
				} else { //add them
					answers[i] = "+";
					answer[i] = firstNum[i] + secNum[i];
					problems[i] = String(firstNum[i]) + " ? " + String(secNum[i]) + " = " + String(answer[i]);
				}
			}
			
		}
		
		/**
		 * Returns a number within the specified range, helper method for the getProblemSet(). 
		 */
		private function randomRange(minNum:Number, maxNum:Number):int  {
			return (Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum);
		}
		
		/**
		 * Sends player back to home screen.
		 */
		public function sendHome(): void {
			game.changeState(Game.PLAY_STATE);
		}
		
		/**
		 * Updates the game background. 
		 */
		public function update():void
		{
			background.update();
			updateCount++;
			
			if (updateCount % 15 == 0 && updateCount % 30 == 0) {
				progress.x += 0.75;
				progress.y += 1.0;
			} else if (updateCount % 15 == 0) {
				//progress.x -= 1.0;
				progress.y -= 1.0;
			}
			
			if (updateCount % 50 == 0 && updateCount % 100 == 0) {
				planet.x += 2.5;
				planet.y += 2.5;
			} else if (updateCount % 50 == 0) {
				planet.x -= 2.5;
				planet.y -= 2.5;
			}
		}
		
		/**
		 * Removes a background or starling object. 
		 */
		public function destroy():void
		{
		}
	}
}
