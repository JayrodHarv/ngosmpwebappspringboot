package com.jayrodharv.ngosmpwebappspringboot.service;

import org.springframework.stereotype.Service;

import com.jayrodharv.ngosmpwebappspringboot.dao.TagDAO;
import com.jayrodharv.ngosmpwebappspringboot.dto.tag.NewTagDTO;
import com.jayrodharv.ngosmpwebappspringboot.dto.tag.TagDTO;

import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@AllArgsConstructor
public class TagService {

    private final TagDAO tagDAO;
    private final AuthorizationService auth;
    private final CurrentUserService currentUserService;

    public TagDTO create(NewTagDTO dto) {

    }
}
