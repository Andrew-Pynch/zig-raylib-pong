const rl = @import("raylib");
const Ball = @import("ball.zig").Ball;
const Paddle = @import("paddle.zig").Paddle;
const Game = @import("game.zig").Game;

pub const SCREEN_WIDTH = 800;
pub const SCREEN_HEIGHT = 400;

pub const MOVEMENT_SPEED: f32 = 5.0;

pub fn main() anyerror!void {
    rl.initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "tut pong");
    defer rl.closeWindow();

    // init audio
    rl.initAudioDevice();
    defer rl.closeAudioDevice();

    const hit_sound = rl.loadSound("assets/hit.wav");
    const score_sound = rl.loadSound("assets/score.ogg");
    defer rl.unloadSound(hit_sound);
    defer rl.unloadSound(score_sound);

    rl.setTargetFPS(60);

    const ball = Ball.init(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, 10, MOVEMENT_SPEED);
    const human = Paddle.init(10, SCREEN_HEIGHT / 2 - 50, 20, 100, .HUMAN);
    const computer = Paddle.init(SCREEN_WIDTH - 30, SCREEN_HEIGHT / 2 - 50, 20, 100, .COMPUTER);
    var game = Game.init(ball, human, computer, hit_sound, score_sound);

    // main game loop
    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.black);

        // UPDATE
        game.update();

        // DRAW
        game.draw();
    }
}
