const std = @import("std");
const rl = @import("raylib");

const main = @import("main.zig");

const Ball = @import("ball.zig").Ball;
const Paddle = @import("paddle.zig").Paddle;

const MAX_SCORE = 10;

pub const Game = struct {
    ball: Ball,
    paddle1: Paddle,
    paddle2: Paddle,
    player1_score: i32,
    player2_score: i32,

    hit_sound: rl.Sound,
    score_sound: rl.Sound,

    pub fn init(ball: Ball, paddle1: Paddle, paddle2: Paddle, hit_sound: rl.Sound, score_sound: rl.Sound) Game {
        return Game{
            .ball = ball,
            .paddle1 = paddle1,
            .paddle2 = paddle2,
            .player1_score = 0,
            .player2_score = 0,

            .hit_sound = hit_sound,
            .score_sound = score_sound,
        };
    }

    pub fn getGame(self: *Game) Game {
        return rl.Game{
            .ball = self.ball,
            .paddle1 = self.paddle1,
            .paddle2 = self.paddle2,
            .player1_score = self.player1_score,
            .player2_score = self.player2_score,
        };
    }

    pub fn bounceBall(self: *Game, paddle: Paddle) void {
        self.ball.speed.x *= -1;
        const relative_intersect_y = (paddle.position.y + (paddle.size.y / 2)) - (self.ball.position.y + (self.ball.size.y / 2));
        const normalized_relative_intersection_y = relative_intersect_y / (paddle.size.y / 2);
        self.ball.speed.y = normalized_relative_intersection_y * (self.ball.speed.x);

        rl.playSound(self.hit_sound);
    }

    pub fn handlePaddleBallCollision(self: *Game) void {
        const ball_rect = self.ball.toRectangle();
        const paddle1_rect = self.paddle1.toRectangle();
        const paddle2_rect = self.paddle2.toRectangle();

        if (rl.checkCollisionRecs(ball_rect, paddle1_rect)) {
            bounceBall(self, self.paddle1);
        }

        if (rl.checkCollisionRecs(ball_rect, paddle2_rect)) {
            bounceBall(self, self.paddle2);
        }
    }

    pub fn handleBallPlayerLoseCollision(self: *Game) void {

        // if ball collides with left wall, paddle 1 loses and paddle 2 gets a point
        if (self.ball.position.x <= 0) {
            self.player2_score += 1;
            self.ball.reset();
            rl.playSound(self.score_sound);
        }

        if (self.ball.position.x + self.ball.size.x >= main.SCREEN_WIDTH) {
            self.player1_score += 1;
            self.ball.reset();
            rl.playSound(self.score_sound);
        }
    }

    pub fn update(self: *Game) void {
        self.paddle1.update(self);
        self.paddle2.update(self);
        self.handlePaddleBallCollision();
        self.handleBallPlayerLoseCollision();
        self.ball.update();
    }

    pub fn draw(self: *Game) void {
        self.paddle1.draw();
        self.paddle2.draw();
        self.ball.draw();

        // Draw FPS
        rl.drawFPS(10, 10);

        // Draw player scores
        const score_font_size = 30;
        const score_y = 40;

        // Player 1 score (left paddle)
        const player1_score_text = std.fmt.allocPrintZ(std.heap.page_allocator, "Player 1: {d}", .{self.player1_score}) catch |err| {
            std.debug.print("Error allocating player1 score text: {}\n", .{err});
            return;
        };
        defer std.heap.page_allocator.free(player1_score_text);
        rl.drawText(player1_score_text, 50, score_y, score_font_size, rl.Color.white);

        // Player 2 score (right paddle)
        const player2_score_text = std.fmt.allocPrintZ(std.heap.page_allocator, "Player 2: {d}", .{self.player2_score}) catch |err| {
            std.debug.print("Error allocating player2 score text: {}\n", .{err});
            return;
        };
        defer std.heap.page_allocator.free(player2_score_text);
        rl.drawText(player2_score_text, main.SCREEN_WIDTH - 200, score_y, score_font_size, rl.Color.white);
    }
};
