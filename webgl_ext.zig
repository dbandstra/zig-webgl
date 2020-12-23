const std = @import("std");

pub const GLchar = u8;

pub const GL_INFO_LOG_LENGTH = 0x8B84;

pub fn glDeleteBuffers(n: GLsizei, buffers: [*c]const GLuint) void {
    var i: usize = 0;
    while (i < n) : (i += 1) {
        glDeleteBuffer(buffers[i]);
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
    glTexImage2D(target, level, internalformat, width, height, border, format, type_, pixels);
}
