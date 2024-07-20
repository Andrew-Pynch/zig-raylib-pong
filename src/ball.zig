const rl = @import("raylib");
const main = @import("main.zig");

pub const Ball = struct {
    position: rl.Vector2,
    size: rl.Vector2,
    speed: rl.Vector2,

    pub fn init(x: f32, y: f32, size: f32, speed: f32) Ball {
        return Ball{ .position = rl.Vector2.init(x, y), .size = rl.Vector2.init(size, size), .speed = rl.Vector2.init(speed, speed) };
    }

    pub fn update(self: *Ball) void {
        self.position = rl.math.vector2Add(self.position, self.speed);

        // border bouncing collisions
        if (self.position.y <= 0 or self.position.y + self.size.y >= main.SCREEN_HEIGHT) {
            self.speed.y *= -1;
        }
        if (self.position.x <= 0 or self.position.x + self.size.x >= main.SCREEN_WIDTH) {
            self.speed.x *= -1;
        }
    }

    pub fn draw(self: *Ball) void {
        rl.drawRectangleV(self.position, self.size, rl.Color.red);
    }

    pub fn toRectangle(self: *Ball) rl.Rectangle {
        return rl.Rectangle{
            .x = self.position.x,
            .y = self.position.y,
            .width = self.size.x,
            .height = self.size.y,
        };
    }

    pub fn reset(self: *Ball) void {
        self.position = rl.Vector2{ .x = main.SCREEN_WIDTH / 2, .y = main.SCREEN_HEIGHT / 2 };
        self.speed = rl.Vector2{ .x = main.MOVEMENT_SPEED, .y = 0 };
    }
};
