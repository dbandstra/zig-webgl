const std = @import("std");

const Func = struct {
    name: []const u8,
    args: []const Arg,
    ret: []const u8,
    js: []const u8,
};

const Arg = struct {
    name: []const u8,
    type: []const u8,
};

// TODO - i don't know what to put for GLboolean... i can't find an explicit
// mention anywhere on what size it should be
// TODO - don't use i64. that gives you "can't convert BigInt to number" errors
const zig_top =
    \\pub const GLenum = c_uint;
    \\pub const GLboolean = bool;
    \\pub const GLbitfield = c_uint;
    \\pub const GLbyte = i8;
    \\pub const GLshort = i16;
    \\pub const GLint = i32;
    \\pub const GLsizei = i32;
    \\pub const GLintptr = i64;
    \\pub const GLsizeiptr = i64;
    \\pub const GLubyte = u8;
    \\pub const GLushort = u16;
    \\pub const GLuint = u32;
    \\pub const GLfloat = f32;
    \\pub const GLclampf = f32;
;

// memory has to be wrapped in a getter because we need the "env" before we can
// even get the memory
const js_top =
    \\function getWebGLEnv(gl, getMemory) {
    \\    const readCharStr = (ptr, len) => {
    \\        const bytes = new Uint8Array(getMemory().buffer, ptr, len);
    \\        let s = "";
    \\        for (let i = 0; i < len; ++i) {
    \\            s += String.fromCharCode(bytes[i]);
    \\        }
    \\        return s;
    \\    };
    \\
    \\    const glShaders = [];
    \\    const glPrograms = [];
    \\    const glBuffers = [];
    \\    const glTextures = [];
    \\    const glFramebuffers = [];
    \\    const glUniformLocations = [];
    \\
;

const js_bottom =
    \\}
;

const funcs = [_]Func{
    Func{
        .name = "getProgramInfoLogLength",
        .args = &[_]Arg{
            .{ .name = "program_id", .type = "GLuint" },
        },
        .ret = "GLint",
        .js =
        \\const log = gl.getProgramInfoLog(glPrograms[program_id]);
        \\if (log === null) return 0;
        \\return new TextEncoder().encode(log).length;
    },
    Func{
        .name = "getShaderInfoLogLength",
        .args = &[_]Arg{
            .{ .name = "shader_id", .type = "GLuint" },
        },
        .ret = "GLint",
        .js =
        \\const log = gl.getShaderInfoLog(glShaders[shader_id]);
        \\if (log === null) return 0;
        \\return new TextEncoder().encode(log).length;
    },
    // actual functions below
    Func{
        .name = "glActiveTexture",
        .args = &[_]Arg{
            .{ .name = "target", .type = "c_uint" },
        },
        .ret = "void",
        .js =
        \\gl.activeTexture(target);
    },
    Func{
        .name = "glAttachShader",
        .args = &[_]Arg{
            .{ .name = "program", .type = "c_uint" },
            .{ .name = "shader", .type = "c_uint" },
        },
        .ret = "void",
        .js =
        \\gl.attachShader(glPrograms[program], glShaders[shader]);
    },
    // TODO - glBindAttribLocation
    Func{
        .name = "glBindBuffer",
        .args = &[_]Arg{
            .{ .name = "type", .type = "c_uint" },
            .{ .name = "buffer_id", .type = "c_uint" },
        },
        .ret = "void",
        .js =
        \\gl.bindBuffer(type, glBuffers[buffer_id]);
    },
    Func{
        .name = "glBindFramebuffer",
        .args = &[_]Arg{
            .{ .name = "target", .type = "c_uint" },
            .{ .name = "framebuffer", .type = "c_uint" },
        },
        .ret = "void",
        .js =
        \\gl.bindFramebuffer(target, glFramebuffers[framebuffer]);
    },
    // TODO - glBindRenderbuffer
    Func{
        .name = "glBindTexture",
        .args = &[_]Arg{
            .{ .name = "target", .type = "c_uint" },
            .{ .name = "texture_id", .type = "c_uint" },
        },
        .ret = "void",
        .js =
        \\gl.bindTexture(target, glTextures[texture_id]);
    },
    // TODO - glBlendColor
    // TODO - glBlendEquation
    // TODO - glBlendEquationSeparate
    Func{
        .name = "glBlendFunc",
        .args = &[_]Arg{
            .{ .name = "x", .type = "c_uint" },
            .{ .name = "y", .type = "c_uint" },
        },
        .ret = "void",
        .js =
        \\gl.blendFunc(x, y);
    },
    // TODO - glBlendFuncSeparate
    Func{
        .name = "glBufferData",
        .args = &[_]Arg{
            .{ .name = "target", .type = "GLenum" },
            .{ .name = "size", .type = "c_uint" }, // GLsizeiptr
            .{ .name = "data", .type = "?*const c_void" }, // TODO maybe `?[*]const u8` instead
            .{ .name = "usage", .type = "GLenum" },
        },
        .ret = "void",
        .js =
        \\if (data === null) {
        \\    gl.bufferData(target, size, usage);
        \\} else {
        \\    const array = new Uint8Array(getMemory().buffer, data, size);
        \\    gl.bufferData(target, array, usage);
        \\}
    },
    // TODO - glBufferSubData
    Func{
        .name = "glCheckFramebufferStatus",
        .args = &[_]Arg{
            .{ .name = "target", .type = "GLenum" },
        },
        .ret = "GLenum",
        .js =
        \\return gl.checkFramebufferStatus(target);
    },
    Func{
        .name = "glClear",
        .args = &[_]Arg{
            .{ .name = "mask", .type = "GLbitfield" },
        },
        .ret = "void",
        .js =
        \\gl.clear(mask);
    },
    Func{
        .name = "glClearColor",
        .args = &[_]Arg{
            .{ .name = "r", .type = "f32" },
            .{ .name = "g", .type = "f32" },
            .{ .name = "b", .type = "f32" },
            .{ .name = "a", .type = "f32" },
        },
        .ret = "void",
        .js =
        \\gl.clearColor(r, g, b, a);
    },
    // TODO - glClearDepth
    // TODO - glClearStencil
    // TODO - glColorMask
    // TODO - glCommit
    Func{
        .name = "glCompileShader",
        .args = &[_]Arg{
            .{ .name = "shader", .type = "GLuint" },
        },
        .ret = "void",
        .js =
        \\gl.compileShader(glShaders[shader]);
    },
    // TODO - glCompressedTexImage2D
    // TODO - glCompressedTexImage3D
    // TODO - glCompressedTexSubImage2D
    // TODO - glCopyTexImage2D
    // TODO - glCopyTexSubImage2D
    Func{
        .name = "glCreateBuffer",
        .args = &[_]Arg{},
        .ret = "c_uint",
        .js =
        \\glBuffers.push(gl.createBuffer());
        \\return glBuffers.length - 1;
    },
    Func{
        .name = "glCreateFramebuffer",
        .args = &[_]Arg{},
        .ret = "GLuint",
        .js =
        \\glFramebuffers.push(gl.createFramebuffer());
        \\return glFramebuffers.length - 1;
    },
    Func{
        .name = "glCreateProgram",
        .args = &[_]Arg{},
        .ret = "GLuint",
        .js =
        \\glPrograms.push(gl.createProgram());
        \\return glPrograms.length - 1;
    },
    // TODO - glCreateRenderbuffer
    Func{
        .name = "glCreateShader",
        .args = &[_]Arg{
            .{ .name = "shader_type", .type = "GLenum" },
        },
        .ret = "GLuint",
        .js =
        \\glShaders.push(gl.createShader(shader_type));
        \\return glShaders.length - 1;
    },
    Func{
        .name = "glCreateTexture",
        .args = &[_]Arg{},
        .ret = "c_uint",
        .js =
        \\glTextures.push(gl.createTexture());
        \\return glTextures.length - 1;
    },
    // TODO - glCullFace
    Func{
        .name = "glDeleteBuffer",
        .args = &[_]Arg{
            .{ .name = "id", .type = "c_uint" },
        },
        .ret = "void",
        .js =
        \\gl.deleteBuffer(glBuffers[id]);
        \\glBuffers[id] = undefined;
    },
    // TODO - glDeleteFramebuffer
    Func{
        .name = "glDeleteProgram",
        .args = &[_]Arg{
            .{ .name = "id", .type = "c_uint" },
        },
        .ret = "void",
        .js =
        \\gl.deleteProgram(glPrograms[id]);
        \\glPrograms[id] = undefined;
    },
    // TODO - glDeleteRenderbuffer
    Func{
        .name = "glDeleteShader",
        .args = &[_]Arg{
            .{ .name = "id", .type = "c_uint" },
        },
        .ret = "void",
        .js =
        \\gl.deleteShader(glShaders[id]);
        \\glShaders[id] = undefined;
    },
    Func{
        .name = "glDeleteTexture",
        .args = &[_]Arg{
            .{ .name = "id", .type = "c_uint" },
        },
        .ret = "void",
        .js =
        \\gl.deleteTexture(glTextures[id]);
        \\glTextures[id] = undefined;
    },
    Func{
        .name = "glDepthFunc",
        .args = &[_]Arg{
            .{ .name = "x", .type = "c_uint" },
        },
        .ret = "void",
        .js =
        \\gl.depthFunc(x);
    },
    // TODO - glDepthMask
    // TODO - glDepthRange
    Func{
        .name = "glDetachShader",
        .args = &[_]Arg{
            .{ .name = "program", .type = "c_uint" },
            .{ .name = "shader", .type = "c_uint" },
        },
        .ret = "void",
        .js =
        \\gl.detachShader(glPrograms[program], glShaders[shader]);
    },
    Func{
        .name = "glDisable",
        .args = &[_]Arg{
            .{ .name = "cap", .type = "GLenum" },
        },
        .ret = "void",
        .js =
        \\gl.disable(cap);
    },
    // TODO - glDisableVertexAttribArray
    Func{
        .name = "glDrawArrays",
        .args = &[_]Arg{
            .{ .name = "mode", .type = "GLenum" },
            .{ .name = "first", .type = "GLint" },
            .{ .name = "count", .type = "GLsizei" },
        },
        .ret = "void",
        .js =
        \\gl.drawArrays(mode, first, count);
    },
    // TODO - glDrawElements
    Func{
        .name = "glEnable",
        .args = &[_]Arg{
            .{ .name = "x", .type = "c_uint" },
        },
        .ret = "void",
        .js =
        \\gl.enable(x);
    },
    Func{
        .name = "glEnableVertexAttribArray",
        .args = &[_]Arg{
            .{ .name = "x", .type = "c_uint" },
        },
        .ret = "void",
        .js =
        \\gl.enableVertexAttribArray(x);
    },
    // TODO - glFinish
    // TODO - glFlush
    // TODO - glFramebufferRenderbuffer
    Func{
        .name = "glFramebufferTexture2D",
        .args = &[_]Arg{
            .{ .name = "target", .type = "GLenum" },
            .{ .name = "attachment", .type = "GLenum" },
            .{ .name = "textarget", .type = "GLenum" },
            .{ .name = "texture", .type = "GLuint" },
            .{ .name = "level", .type = "GLint" },
        },
        .ret = "void",
        .js =
        \\gl.framebufferTexture2D(target, attachment, textarget, glTextures[texture], level);
    },
    Func{
        .name = "glFrontFace",
        .args = &[_]Arg{
            .{ .name = "mode", .type = "GLenum" },
        },
        .ret = "void",
        .js =
        \\gl.frontFace(mode);
    },
    // TODO - glGenerateMipmap
    // TODO - glGetActiveAttrib
    // TODO - glGetActiveUniform
    // TODO - glGetAttachedShaders
    Func{
        .name = "glGetAttribLocation",
        .args = &[_]Arg{
            .{ .name = "program_id", .type = "c_uint" },
            .{ .name = "name", .type = "STRING" },
        },
        .ret = "c_int",
        .js =
        \\return gl.getAttribLocation(glPrograms[program_id], name);
    },
    // TODO - glGetBufferParameter
    // TODO - glGetContextAttributes
    Func{
        .name = "glGetError",
        .args = &[_]Arg{},
        .ret = "c_int",
        .js =
        \\return gl.getError();
    },
    // TODO - glGetExtension
    // TODO - glGetFramebufferAttachmentParameter
    // TODO - glGetParameter
    Func{
        .name = "glGetProgramInfoLog_api",
        .args = &[_]Arg{
            .{ .name = "program_id", .type = "c_uint" },
            .{ .name = "ptr", .type = "[*]u8" },
            .{ .name = "len", .type = "c_uint" },
        },
        .ret = "c_uint",
        .js =
        \\const log = gl.getProgramInfoLog(glPrograms[program_id]);
        \\if (log === null) return 0;
        \\
        \\const encoded = new TextEncoder().encode(log);
        \\const outbuf = new Uint8Array(getMemory().buffer, ptr, len);
        \\
        \\for (let i = 0; i < len && i < encoded.length; i++) {
        \\    outbuf[i] = encoded[i];
        \\}
        \\
        \\// TODO do something with Uint8Array::set? like this:
        \\//const dest = new Uint8Array(memory.buffer, memory_index, asset.bytes.byteLength);
        \\//const src = new Uint8Array(asset.bytes);
        \\//dest.set(src);
        \\
        \\return encoded.length;
    },
    Func{
        .name = "glGetProgramParameter",
        .args = &[_]Arg{
            .{ .name = "program_id", .type = "c_uint" },
            .{ .name = "pname", .type = "GLenum" },
        },
        // FIXME - return type can actually be GLboolean or GLint depending on
        // pname, see the docs at khronos.org
        .ret = "GLint",
        .js =
        \\const result = gl.getProgramParameter(glPrograms[program_id], pname);
        \\if (result === null) return 0;
        \\if (result === false) return 0;
        \\if (result === true) return 1;
        \\return result;
    },
    // TODO - glGetRenderbufferParameter
    Func{
        //fn (GLuint, GLsizei, [*c]GLsizei, [*c]GLchar) callconv(cc) void;
        .name = "glGetShaderInfoLog_api",
        .args = &[_]Arg{
            .{ .name = "shader_id", .type = "c_uint" },
            .{ .name = "ptr", .type = "[*]u8" },
            .{ .name = "len", .type = "c_uint" },
        },
        .ret = "c_uint",
        .js =
        \\const log = gl.getShaderInfoLog(glShaders[shader_id]);
        \\if (log === null) return 0;
        \\
        \\const encoded = new TextEncoder().encode(log);
        \\const outbuf = new Uint8Array(getMemory().buffer, ptr, len);
        \\
        \\for (let i = 0; i < len && i < encoded.length; i++) {
        \\    outbuf[i] = encoded[i];
        \\}
        \\
        \\// TODO do something with Uint8Array::set? like this:
        \\//const dest = new Uint8Array(memory.buffer, memory_index, asset.bytes.byteLength);
        \\//const src = new Uint8Array(asset.bytes);
        \\//dest.set(src);
        \\
        \\return encoded.length;
    },
    Func{
        .name = "glGetShaderParameter",
        .args = &[_]Arg{
            .{ .name = "shader_id", .type = "c_uint" },
            .{ .name = "pname", .type = "GLenum" },
        },
        // FIXME - return type is actually supposed to be GLenum if pname is SHADER_TYPE,
        // or GLboolean if pname is DELETE_STATUS or COMPILE_STATUS.
        .ret = "GLenum",
        .js =
        \\const result = gl.getShaderParameter(glShaders[shader_id], pname);
        \\if (result === null) return 0;
        \\if (result === false) return 0;
        \\if (result === true) return 1;
        \\return result;
    },
    // TODO - glGetShaderPrecisionFormat
    // TODO - glGetShaderSource
    // TODO - glGetSupportedExtensions
    // TODO - glGetTexParameter
    // TODO - glGetUniform
    Func{
        .name = "glGetUniformLocation",
        .args = &[_]Arg{
            .{ .name = "program_id", .type = "c_uint" },
            .{ .name = "name", .type = "STRING" },
        },
        .ret = "c_int",
        .js =
        \\glUniformLocations.push(gl.getUniformLocation(glPrograms[program_id], name));
        \\return glUniformLocations.length - 1;
    },
    // TODO - glGetVertexAttrib
    // TODO - glGetVertexAttribOffset
    // TODO - glHint
    // TODO - glIsBuffer
    // TODO - glIsContextLost
    // TODO - glIsEnabled
    // TODO - glIsFramebuffer
    // TODO - glIsProgram
    // TODO - glIsRenderbuffer
    // TODO - glIsShader
    // TODO - glIsTexture
    // TODO - glLineWidth
    Func{
        .name = "glLinkProgram",
        .args = &[_]Arg{
            .{ .name = "program", .type = "c_uint" },
        },
        .ret = "void",
        .js =
        \\gl.linkProgram(glPrograms[program]);
    },
    Func{
        .name = "glPixelStorei",
        .args = &[_]Arg{
            .{ .name = "pname", .type = "GLenum" },
            .{ .name = "param", .type = "GLint" },
        },
        .ret = "void",
        .js =
        \\gl.pixelStorei(pname, param);
    },
    // TODO - glPolygonOffset
    // TODO - glReadPixels
    // TODO - glRenderbufferStorage
    // TODO - glSampleCoverage
    // TODO - glScissor
    Func{
        .name = "glShaderSource_api",
        .args = &[_]Arg{
            .{ .name = "shader", .type = "GLuint" },
            .{ .name = "string", .type = "STRING" },
        },
        .ret = "void",
        .js =
        \\gl.shaderSource(glShaders[shader], string);
    },
    // TODO - glStencilFunc
    // TODO - glStencilFuncSeparate
    // TODO - glStencilMask
    // TODO - glStencilMaskSeparate
    // TODO - glStencilOp
    // TODO - glStencilOpSeparate
    Func{
        .name = "glTexImage2D_api",
        .args = &[_]Arg{
            .{ .name = "target", .type = "GLenum" },
            .{ .name = "level", .type = "GLint" },
            .{ .name = "internal_format", .type = "GLint" },
            .{ .name = "width", .type = "GLsizei" },
            .{ .name = "height", .type = "GLsizei" },
            .{ .name = "border", .type = "GLint" },
            .{ .name = "format", .type = "GLenum" },
            .{ .name = "type_", .type = "GLenum" },
            .{ .name = "pixels_ptr", .type = "?*c_void" },
            .{ .name = "pixels_len", .type = "usize" },
        },
        .ret = "void",
        .js =
        \\if (pixels_ptr === null) {
        \\    gl.texImage2D(target, level, internal_format, width, height, border, format, type_, null);
        \\} else {
        \\    const data = (type_ === gl.UNSIGNED_BYTE)
        \\        ? new Uint8Array(getMemory().buffer, pixels, pixels_len)
        \\        : new Uint16Array(getMemory().buffer, pixels, pixels_len / 2);
        \\    gl.texImage2D(target, level, internal_format, width, height, border, format, type_, data);
        \\}
    },
    Func{
        .name = "glTexParameterf",
        .args = &[_]Arg{
            .{ .name = "target", .type = "c_uint" },
            .{ .name = "pname", .type = "c_uint" },
            .{ .name = "param", .type = "f32" },
        },
        .ret = "void",
        .js =
        \\gl.texParameterf(target, pname, param);
    },
    Func{
        .name = "glTexParameteri",
        .args = &[_]Arg{
            .{ .name = "target", .type = "c_uint" },
            .{ .name = "pname", .type = "c_uint" },
            .{ .name = "param", .type = "c_uint" },
        },
        .ret = "void",
        .js =
        \\gl.texParameteri(target, pname, param);
    },
    // TODO - glTexSubImage2D
    Func{
        .name = "glUniform1f",
        .args = &[_]Arg{
            .{ .name = "location_id", .type = "c_int" },
            .{ .name = "x", .type = "f32" },
        },
        .ret = "void",
        .js =
        \\gl.uniform1f(glUniformLocations[location_id], x);
    },
    // TODO - glUniform1fv
    Func{
        .name = "glUniform1i",
        .args = &[_]Arg{
            .{ .name = "location_id", .type = "c_int" },
            .{ .name = "x", .type = "c_int" },
        },
        .ret = "void",
        .js =
        \\gl.uniform1i(glUniformLocations[location_id], x);
    },
    // TODO - glUniform1iv
    // TODO - glUniform2f
    // TODO - glUniform2fv
    // TODO - glUniform2i
    // TODO - glUniform2iv
    // TODO - glUniform3f
    // TODO - glUniform3fv
    // TODO - glUniform3i
    // TODO - glUniform3iv
    Func{
        .name = "glUniform4f",
        .args = &[_]Arg{
            .{ .name = "location_id", .type = "c_int" },
            .{ .name = "x", .type = "f32" },
            .{ .name = "y", .type = "f32" },
            .{ .name = "z", .type = "f32" },
            .{ .name = "w", .type = "f32" },
        },
        .ret = "void",
        .js =
        \\gl.uniform4f(glUniformLocations[location_id], x, y, z, w);
    },
    // TODO - glUniform4fv
    // TODO - glUniform4i
    // TODO - glUniform4iv
    // TODO - glUniformMatrix2fv
    // TODO - glUniformMatrix3fv
    Func{
        .name = "glUniformMatrix4fv",
        // FIXME - take three args, not four.. transpose should be second arg
        .args = &[_]Arg{
            .{ .name = "location_id", .type = "c_int" },
            .{ .name = "data_len", .type = "c_int" },
            .{ .name = "transpose", .type = "c_uint" },
            .{ .name = "data_ptr", .type = "[*]const f32" },
        },
        .ret = "void",
        .js =
        \\const floats = new Float32Array(getMemory().buffer, data_ptr, data_len * 16);
        \\gl.uniformMatrix4fv(glUniformLocations[location_id], transpose, floats);
    },
    Func{
        .name = "glUseProgram",
        .args = &[_]Arg{
            .{ .name = "program_id", .type = "c_uint" },
        },
        .ret = "void",
        .js =
        \\gl.useProgram(glPrograms[program_id]);
    },
    // TODO - glValidateProgram
    // TODO - glVertexAttrib1f
    // TODO - glVertexAttrib1fv
    // TODO - glVertexAttrib2f
    // TODO - glVertexAttrib2fv
    // TODO - glVertexAttrib3f
    // TODO - glVertexAttrib3fv
    // TODO - glVertexAttrib4f
    // TODO - glVertexAttrib4fv
    Func{
        .name = "glVertexAttribPointer",
        .args = &[_]Arg{
            .{ .name = "attrib_location", .type = "c_uint" },
            .{ .name = "size", .type = "c_uint" },
            .{ .name = "type", .type = "c_uint" },
            .{ .name = "normalize", .type = "c_uint" },
            .{ .name = "stride", .type = "c_uint" },
            .{ .name = "offset", .type = "[*c]const c_uint" },
        },
        .ret = "void",
        .js =
        \\gl.vertexAttribPointer(attrib_location, size, type, normalize, stride, offset);
    },
    Func{
        .name = "glViewport",
        .args = &[_]Arg{
            .{ .name = "x", .type = "c_int" },
            .{ .name = "y", .type = "c_int" },
            .{ .name = "width", .type = "c_int" },
            .{ .name = "height", .type = "c_int" },
        },
        .ret = "void",
        .js =
        \\gl.viewport(x, y, width, height);
    },
};

fn nextNewline(s: []const u8) usize {
    for (s) |ch, i| {
        if (ch == '\n') {
            return i;
        }
    }
    return s.len;
}

fn writeZigFile(filename: []const u8) !void {
    const file = try std.fs.cwd().createFile(filename, .{});
    defer file.close();

    var stream = file.outStream();

    try stream.print("{}\n\n", .{zig_top});

    for (funcs) |func| {
        const any_slice = for (func.args) |arg| {
            if (std.mem.eql(u8, arg.type, "STRING")) break true;
        } else false;

        // https://github.com/ziglang/zig/issues/3882
        const fmtarg_pub = if (any_slice) "" else "pub ";
        const fmtarg_suf = if (any_slice) "_" else "";
        try stream.print("{}extern fn {}{}(", .{ fmtarg_pub, func.name, fmtarg_suf });
        for (func.args) |arg, i| {
            if (i > 0) {
                try stream.print(", ", .{});
            }
            if (std.mem.eql(u8, arg.type, "STRING")) {
                try stream.print("{}_ptr: [*]const u8, {}_len: c_uint", .{ arg.name, arg.name });
            } else {
                try stream.print("{}: {}", .{ arg.name, arg.type });
            }
        }
        try stream.print(") {};\n", .{func.ret});

        if (any_slice) {
            try stream.print("pub fn {}(", .{func.name});
            for (func.args) |arg, i| {
                if (i > 0) {
                    try stream.print(", ", .{});
                }
                if (std.mem.eql(u8, arg.type, "STRING")) {
                    try stream.print("{}: []const u8", .{arg.name});
                } else {
                    try stream.print("{}: {}", .{ arg.name, arg.type });
                }
            }
            try stream.print(") {} {{\n", .{func.ret});
            // https://github.com/ziglang/zig/issues/3882
            const fmtarg_ret = if (std.mem.eql(u8, func.ret, "void")) "" else "return ";
            try stream.print("    {}{}_(", .{ fmtarg_ret, func.name });
            for (func.args) |arg, i| {
                if (i > 0) {
                    try stream.print(", ", .{});
                }
                if (std.mem.eql(u8, arg.type, "STRING")) {
                    try stream.print("{}.ptr, {}.len", .{ arg.name, arg.name });
                } else {
                    try stream.print("{}", .{arg.name});
                }
            }
            try stream.print(");\n", .{});
            try stream.print("}}\n", .{});
        }
    }
}

fn writeJsFile(filename: []const u8) !void {
    const file = try std.fs.cwd().createFile(filename, .{});
    defer file.close();

    var stream = file.outStream();

    try stream.print("{}\n", .{js_top});

    try stream.print("    return {{\n", .{});
    for (funcs) |func| {
        const any_slice = for (func.args) |arg| {
            if (std.mem.eql(u8, arg.type, "STRING")) break true;
        } else false;

        // https://github.com/ziglang/zig/issues/3882
        const fmtarg_suf = if (any_slice) "_" else "";
        try stream.print("        {}{}(", .{ func.name, fmtarg_suf });
        for (func.args) |arg, i| {
            if (i > 0) {
                try stream.print(", ", .{});
            }
            if (std.mem.eql(u8, arg.type, "STRING")) {
                try stream.print("{}_ptr, {}_len", .{ arg.name, arg.name });
            } else {
                try stream.print("{}", .{arg.name});
            }
        }
        try stream.print(") {{\n", .{});
        for (func.args) |arg| {
            if (std.mem.eql(u8, arg.type, "STRING")) {
                try stream.print("            const {} = readCharStr({}_ptr, {}_len);\n", .{ arg.name, arg.name, arg.name });
            }
        }
        var start: usize = 0;
        while (start < func.js.len) {
            const rel_newline_pos = nextNewline(func.js[start..]);
            const slice = func.js[start .. start + rel_newline_pos];
            if (slice.len > 0) {
                try stream.print("            {}\n", .{slice});
            } else {
                try stream.print("\n", .{});
            }
            start += rel_newline_pos + 1;
        }
        try stream.print("        }},\n", .{});
    }
    try stream.print("    }};\n", .{});

    try stream.print("{}\n", .{js_bottom});
}

pub fn main() !void {
    try writeZigFile("generated/webgl.zig");
    try writeJsFile("generated/webgl_bindings.js");
}
