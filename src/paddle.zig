const rl = @import("raylib");
const std = @import("std");

const main = @import("main.zig");
const Game = @import("game.zig").Game;

const MOVEMENT_SPEED: f32 = 5.0;

pub const PaddleControlMode = enum { HUMAN, COMPUTER };

pub const Paddle = struct {
    position: rl.Vector2,
    size: rl.Vector2,
    speed: rl.Vector2,
    control_mode: PaddleControlMode,

    pub fn init(x: f32, y: f32, width: f32, height: f32, control_mode: PaddleControlMode) Paddle {
        return Paddle{
            .position = rl.Vector2{ .x = x, .y = y },
            .size = rl.Vector2{ .x = width, .y = height },
            .speed = rl.Vector2{ .x = 0, .y = 0 },
            .control_mode = control_mode,
        };
    }

    pub fn handleInput(self: *Paddle) void {
        // Move up while the up key is presse
        if (rl.isKeyDown(rl.KeyboardKey.key_up)) {
            self.speed.y = -MOVEMENT_SPEED;
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_down)) {
            self.speed.y = MOVEMENT_SPEED;
        }
    }

    pub fn handleComputerControl(self: *Paddle, game: *Game) void {
        // check if ball is above paddle, move paddle up
        if (game.ball.position.y < self.position.y) {
            self.speed.y = -MOVEMENT_SPEED;
        }

        // check if ball is below paddle, move paddle down
        if (game.ball.position.y > self.position.y) {
            self.speed.y = MOVEMENT_SPEED;
        }
    }

    pub fn update(self: *Paddle, game: *Game) void {
        // Reset speed at the beginning of each update
        self.speed.y = 0;

        switch (self.control_mode) {
            .HUMAN => self.handleInput(),
            .COMPUTER => self.handleComputerControl(game),
        }

        // Update position
        self.position = rl.math.vector2Add(self.position, self.speed);

        // Ensure the paddle stays within the screen boundaries
        self.position.y = @max(0, @min(self.position.y, main.SCREEN_HEIGHT - self.size.y));
    }

    pub fn draw(self: *Paddle) void {
        rl.drawRectangleV(self.position, self.size, rl.Color.green);
    }

    pub fn toRectangle(self: *Paddle) rl.Rectangle {
        return rl.Rectangle{
            .x = self.position.x,
            .y = self.position.y,
            .width = self.size.x,
            .height = self.size.y,
        };
    }

    pub fn reset(self: *Paddle) void {
        // set position to center of screen and give slight random speed
        self.position = rl.Vector2{ .x = main.SCREEN_WIDTH / 2, .y = main.SCREEN_HEIGHT / 2 };
        self.speed = rl.Vector2{ .x = 0, .y = 0 };
    }
};
