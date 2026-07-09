package com.jayrodharv.ngosmpwebappspringboot.service;

import java.util.List;

import com.jayrodharv.ngosmpwebappspringboot.dto.tag.NewTagDTO;
import com.jayrodharv.ngosmpwebappspringboot.dto.tag.TagDTO;

public interface TagService {
    Integer create(NewTagDTO dto);

    List<TagDTO> getList();

    TagDTO get();

    void update(TagDTO dto);

    void delete(Integer tagId);
}
