package com.jayrodharv.ngosmpwebappspringboot.controller;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.jayrodharv.ngosmpwebappspringboot.dto.tag.NewTagDTO;
import com.jayrodharv.ngosmpwebappspringboot.service.TagService;

import lombok.AllArgsConstructor;

@RestController
@RequestMapping("/api/tags")
@AllArgsConstructor
public class TagRestController {

    private final TagService tagService;

    @PostMapping("/new")
    public Integer createTag(@RequestBody NewTagDTO dto) {
        return tagService.create(dto);
    }

}
