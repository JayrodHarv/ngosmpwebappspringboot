package com.jayrodharv.ngosmpwebappspringboot.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.*;

/**
 * Registers the upload directory as a static resource location
 * so images stored on disk are accessible at /uploads/**
 */
@Configuration
public class MvcConfig implements WebMvcConfigurer {

    @Value("${app.upload.dir:./uploads}")
    private String uploadDir;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // Ensures the path ends with a separator
        String location = uploadDir.endsWith("/") ? uploadDir : uploadDir + "/";

        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("file:" + location);
    }
}
