function getWebGLEnv(gl, getMemory) {
    const readCharStr = (ptr, len) => {
        const bytes = new Uint8Array(getMemory().buffer, ptr, len);
        let s = "";
        for (let i = 0; i < len; ++i) {
            s += String.fromCharCode(bytes[i]);
        }
        return s;
    };

    const getBytesPerPixel = (format, type) => {
        switch (type) {
            case gl.UNSIGNED_BYTE:
                switch (format) {
                    case gl.RGBA:
                        return 4;
                    case gl.RGB:
                        return 3;
                    case gl.LUMINANCE_ALPHA:
                        return 2;
                    case gl.LUMINANCE:
                    case gl.ALPHA:
                        return 1;
                }
                break;
            case gl.UNSIGNED_SHORT_4_4_4_4:
                if (format === gl.RGBA)
                    return 2;
                break;
            case gl.UNSIGNED_SHORT_5_5_5_1:
                if (format === gl.RGBA)
                    return 2;
                break;
            case gl.UNSIGNED_SHORT_5_6_5:
                if (format === gl.RGB)
                    return 2;
                break;
        }
        return 0; // invalid
    };

    const glShaders = [];
    const glPrograms = [];
    const glBuffers = [];
    const glTextures = [];
    const glFramebuffers = [];
    const glUniformLocations = [];

    return {
        getProgramInfoLogLength(program_id) {
            const log = gl.getProgramInfoLog(glPrograms[program_id]);
            if (log === null) return 0;
            return new TextEncoder().encode(log).length;
        },
        getShaderInfoLogLength(shader_id) {
            const log = gl.getShaderInfoLog(glShaders[shader_id]);
            if (log === null) return 0;
            return new TextEncoder().encode(log).length;
        },
        glActiveTexture(target) {
            gl.activeTexture(target);
        },
        glAttachShader(program, shader) {
            gl.attachShader(glPrograms[program], glShaders[shader]);
        },
        glBindBuffer(type, buffer_id) {
            gl.bindBuffer(type, glBuffers[buffer_id]);
        },
        glBindFramebuffer(target, framebuffer) {
            gl.bindFramebuffer(target, glFramebuffers[framebuffer]);
        },
        glBindTexture(target, texture_id) {
            gl.bindTexture(target, glTextures[texture_id]);
        },
        glBlendFunc(x, y) {
            gl.blendFunc(x, y);
        },
        glBufferData(target, size, data, usage) {
            if (data === null) {
                gl.bufferData(target, size, usage);
            } else {
                const array = new Uint8Array(getMemory().buffer, data, size);
                gl.bufferData(target, array, usage);
            }
        },
        glCheckFramebufferStatus(target) {
            return gl.checkFramebufferStatus(target);
        },
        glClear(mask) {
            gl.clear(mask);
        },
        glClearColor(r, g, b, a) {
            gl.clearColor(r, g, b, a);
        },
        glCompileShader(shader) {
            gl.compileShader(glShaders[shader]);
        },
        glCreateBuffer() {
            glBuffers.push(gl.createBuffer());
            return glBuffers.length - 1;
        },
        glCreateFramebuffer() {
            glFramebuffers.push(gl.createFramebuffer());
            return glFramebuffers.length - 1;
        },
        glCreateProgram() {
            glPrograms.push(gl.createProgram());
            return glPrograms.length - 1;
        },
        glCreateShader(shader_type) {
            glShaders.push(gl.createShader(shader_type));
            return glShaders.length - 1;
        },
        glCreateTexture() {
            glTextures.push(gl.createTexture());
            return glTextures.length - 1;
        },
        glDeleteBuffer(id) {
            gl.deleteBuffer(glBuffers[id]);
            glBuffers[id] = undefined;
        },
        glDeleteProgram(id) {
            gl.deleteProgram(glPrograms[id]);
            glPrograms[id] = undefined;
        },
        glDeleteShader(id) {
            gl.deleteShader(glShaders[id]);
            glShaders[id] = undefined;
        },
        glDeleteTexture(id) {
            gl.deleteTexture(glTextures[id]);
            glTextures[id] = undefined;
        },
        glDepthFunc(x) {
            gl.depthFunc(x);
        },
        glDetachShader(program, shader) {
            gl.detachShader(glPrograms[program], glShaders[shader]);
        },
        glDisable(cap) {
            gl.disable(cap);
        },
        glDrawArrays(mode, first, count) {
            gl.drawArrays(mode, first, count);
        },
        glEnable(x) {
            gl.enable(x);
        },
        glEnableVertexAttribArray(x) {
            gl.enableVertexAttribArray(x);
        },
        glFramebufferTexture2D(target, attachment, textarget, texture, level) {
            gl.framebufferTexture2D(target, attachment, textarget, glTextures[texture], level);
        },
        glFrontFace(mode) {
            gl.frontFace(mode);
        },
        glGetAttribLocation_(program_id, name_ptr, name_len) {
            const name = readCharStr(name_ptr, name_len);
            return gl.getAttribLocation(glPrograms[program_id], name);
        },
        glGetError() {
            return gl.getError();
        },
        glGetProgramInfoLog_api(program_id, ptr, len) {
            const log = gl.getProgramInfoLog(glPrograms[program_id]);
            if (log === null) return 0;

            const encoded = new TextEncoder().encode(log);
            const outbuf = new Uint8Array(getMemory().buffer, ptr, len);

            for (let i = 0; i < len && i < encoded.length; i++) {
                outbuf[i] = encoded[i];
            }

            // TODO do something with Uint8Array::set? like this:
            //const dest = new Uint8Array(memory.buffer, memory_index, asset.bytes.byteLength);
            //const src = new Uint8Array(asset.bytes);
            //dest.set(src);

            return encoded.length;
        },
        glGetProgramParameter(program_id, pname) {
            const result = gl.getProgramParameter(glPrograms[program_id], pname);
            if (result === null) return 0;
            if (result === false) return 0;
            if (result === true) return 1;
            return result;
        },
        glGetShaderInfoLog_api(shader_id, ptr, len) {
            const log = gl.getShaderInfoLog(glShaders[shader_id]);
            if (log === null) return 0;

            const encoded = new TextEncoder().encode(log);
            const outbuf = new Uint8Array(getMemory().buffer, ptr, len);

            for (let i = 0; i < len && i < encoded.length; i++) {
                outbuf[i] = encoded[i];
            }

            // TODO do something with Uint8Array::set? like this:
            //const dest = new Uint8Array(memory.buffer, memory_index, asset.bytes.byteLength);
            //const src = new Uint8Array(asset.bytes);
            //dest.set(src);

            return encoded.length;
        },
        glGetShaderParameter(shader_id, pname) {
            const result = gl.getShaderParameter(glShaders[shader_id], pname);
            if (result === null) return 0;
            if (result === false) return 0;
            if (result === true) return 1;
            return result;
        },
        glGetUniformLocation_(program_id, name_ptr, name_len) {
            const name = readCharStr(name_ptr, name_len);
            glUniformLocations.push(gl.getUniformLocation(glPrograms[program_id], name));
            return glUniformLocations.length - 1;
        },
        glLinkProgram(program) {
            gl.linkProgram(glPrograms[program]);
        },
        glPixelStorei(pname, param) {
            gl.pixelStorei(pname, param);
        },
        glShaderSource_api_(shader, string_ptr, string_len) {
            const string = readCharStr(string_ptr, string_len);
            gl.shaderSource(glShaders[shader], string);
        },
        glTexImage2D_api(target, level, internal_format, width, height, border, format, type_, pixels) {
            if (pixels === null) {
                gl.texImage2D(target, level, internal_format, width, height, border, format, type_, null);
            } else {
                const bytes_per_pixel = getBytesPerPixel(format, type_);
                if (bytes_per_pixel === 0) return; // invalid (TODO set gl error?)

                const pixels_len = width * height * bytes_per_pixel;

                const data = (type_ === gl.UNSIGNED_BYTE)
                    ? new Uint8Array(getMemory().buffer, pixels, pixels_len)
                    : new Uint16Array(getMemory().buffer, pixels, pixels_len / 2);

                gl.texImage2D(target, level, internal_format, width, height, border, format, type_, data);
            }
        },
        glTexParameterf(target, pname, param) {
            gl.texParameterf(target, pname, param);
        },
        glTexParameteri(target, pname, param) {
            gl.texParameteri(target, pname, param);
        },
        glUniform1f(location_id, x) {
            gl.uniform1f(glUniformLocations[location_id], x);
        },
        glUniform1i(location_id, x) {
            gl.uniform1i(glUniformLocations[location_id], x);
        },
        glUniform4f(location_id, x, y, z, w) {
            gl.uniform4f(glUniformLocations[location_id], x, y, z, w);
        },
        glUniformMatrix4fv(location_id, data_len, transpose, data_ptr) {
            const floats = new Float32Array(getMemory().buffer, data_ptr, data_len * 16);
            gl.uniformMatrix4fv(glUniformLocations[location_id], transpose, floats);
        },
        glUseProgram(program_id) {
            gl.useProgram(glPrograms[program_id]);
        },
        glVertexAttribPointer(attrib_location, size, type, normalize, stride, offset) {
            gl.vertexAttribPointer(attrib_location, size, type, normalize, stride, offset);
        },
        glViewport(x, y, width, height) {
            gl.viewport(x, y, width, height);
        },
    };
}
