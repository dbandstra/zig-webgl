const std = @import("std");

pub const GLchar = u8;

pub const GL_INFO_LOG_LENGTH = 0x8B84;

pub fn glDeleteBuffers(n: GLsizei, buffers: [*c]const GLuint) void {
    var i: usize = 0;
    while (i < n) : (i += 1) {
        glDeleteBuffer(buffers[i]);
    }
}

pub fn glDeleteTextures(n: GLsizei, textures: [*c]const GLuint) void {
    var i: usize = 0;
    while (i < n) : (i += 1) {
        glDeleteTexture(textures[i]);
    }
}

pub fn glGenBuffers(n: GLsizei, buffers: [*c]GLuint) void {
    var i: usize = 0;
    while (i < n) : (i += 1) {
        buffers[i] = glCreateBuffer();
    }
}

pub fn glGenTextures(n: GLsizei, textures: [*c]GLuint) void {
    var i: usize = 0;
    while (i < n) : (i += 1) {
        textures[i] = glCreateTexture();
    }
}

pub fn glGetProgramInfoLog(
    program: GLuint,
    max_length: GLsizei,
    length: [*c]GLsizei,
    info_log: [*c]GLchar,
) void {
    const n = glGetProgramInfoLog_api(program, info_log, @intCast(c_uint, max_length));
    length.* = @intCast(GLsizei, n);
}

pub fn glGetProgramiv(program: GLuint, pname: GLenum, params: *GLint) void {
    switch (pname) {
        GL_LINK_STATUS => {
            const status = glGetProgramParameter(program, GL_LINK_STATUS);
            params.* = @intCast(GLint, status);
        },
        GL_INFO_LOG_LENGTH => {
            params.* = getProgramInfoLogLength(program);
        },
        // TODO do a proper panic if we know the enum SHOULD be handled?
        else => unreachable, // FIXME set GL_INVALID_ENUM
        // (need to wrap error handling to make this possible...)
    }
}

pub fn glGetShaderInfoLog(
    shader: GLuint,
    max_length: GLsizei,
    length: [*c]GLsizei,
    info_log: [*c]GLchar,
) void {
    const n = glGetShaderInfoLog_api(shader, info_log, @intCast(c_uint, max_length));
    length.* = @intCast(GLsizei, n);
}

pub fn glGetShaderiv(shader: GLuint, pname: GLenum, params: *GLint) void {
    switch (pname) {
        GL_COMPILE_STATUS => {
            const status = glGetShaderParameter(shader, GL_COMPILE_STATUS);
            params.* = @intCast(GLint, status);
        },
        GL_INFO_LOG_LENGTH => {
            params.* = getShaderInfoLogLength(shader);
        },
        // TODO do a proper panic if we know the enum SHOULD be handled?
        else => unreachable, // FIXME set GL_INVALID_ENUM
        // (need to wrap error handling to make this possible...)
    }
}

pub fn glShaderSource(
    shader: GLuint,
    count: GLsizei,
    string: [*c]const [*c]const GLchar,
    length: [*c]const GLint,
) void {
    // TODO what happens when count > 1? it's just like concatenating the strings?
    // implement that on the javascript side.
    std.debug.assert(count == 1);

    const str: []const u8 = blk: {
        if (length) |ilengths| {
            if (ilengths[0] >= 0) {
                const ulen = @intCast(usize, ilengths[0]);
                break :blk string[0][0..ulen];
            }
        }
        break :blk std.mem.spanZ(string[0]);
    };

    glShaderSource_api(shader, str);
}

fn getBytesPerPixel(format: GLenum, type_: GLenum) GLsizei {
    switch (type_) {
        GL_UNSIGNED_BYTE => return switch (format) {
            GL_RGBA => 4,
            GL_RGB => 3,
            GL_LUMINANCE_ALPHA => 2,
            GL_LUMINANCE, GL_ALPHA => 1,
            else => 0,
        },
        GL_UNSIGNED_SHORT_4_4_4_4 => return switch (format) {
            GL_RGBA => 2,
            else => 0,
        },
        GL_UNSIGNED_SHORT_5_5_5_1 => return switch (format) {
            GL_RGBA => 2,
            else => 0,
        },
        GL_UNSIGNED_SHORT_5_6_5 => return switch (format) {
            GL_RGB => 2,
            else => 0,
        },
        else => return 0,
    }
}

pub fn glTexImage2D(
    target: GLenum,
    level: GLint,
    internalformat: GLint,
    width: GLsizei,
    height: GLsizei,
    border: GLint,
    format: GLenum,
    type_: GLenum,
    pixels: ?*const c_void,
) void {
    if (pixels == null) {
        glTexImage2D_api(target, level, internalformat, width, height, border, format, type_, null, 0);
    } else {
        const bytes_per_pixel = getBytesPerPixel(format, type_);
        if (bytes_per_pixel == 0) return; // invalid (TODO set gl error?)

        const pixels_len = width * height * bytes_per_pixel;

        glTexImage2D_api(target, level, internalformat, width, height, border, format, type_, pixels, pixels_len);
    }
}

pub fn glUniform2fv(location_id: c_int, count: GLsizei, value: *const [2]f32) void {
    std.debug.assert(count == 1);
    glUniform2f(location_id, value[0], value[1]);
}

pub fn glUniform3fv(location_id: c_int, count: GLsizei, value: *const [3]f32) void {
    std.debug.assert(count == 1);
    glUniform3f(location_id, value[0], value[1], value[2]);
}

pub fn glUniform4fv(location_id: c_int, count: GLsizei, value: *const [4]f32) void {
    std.debug.assert(count == 1);
    glUniform4f(location_id, value[0], value[1], value[2], value[3]);
}

// webgl2:

pub fn glDeleteQueries(n: GLsizei, queries: [*c]GLuint) void {
    var i: usize = 0;
    while (i < n) : (i += 1) {
        glDeleteQuery(queries[i]);
    }
}

pub fn glGenQueries(n: GLsizei, queries: [*c]GLuint) void {
    var i: usize = 0;
    while (i < n) : (i += 1) {
        queries[i] = glCreateQuery();
    }
}

pub fn glGenVertexArrays(n: GLsizei, vaos: [*c]GLuint) void {
    var i: usize = 0;
    while (i < n) : (i += 1) {
        vaos[i] = glCreateVertexArray();
    }
}

pub fn glGetQueryObjectiv(query_id: GLuint, pname: GLenum, params: [*c]GLint) void {
    params.* = glGetQueryParameter(query_id, pname);
}
