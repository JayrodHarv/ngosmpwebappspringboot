package com.jayrodharv.ngosmpwebappspringboot.service;

import com.jayrodharv.ngosmpwebappspringboot.config.CustomUserDetails;
import com.jayrodharv.ngosmpwebappspringboot.dao.BuildDAO;
import com.jayrodharv.ngosmpwebappspringboot.dao.BuildImageDAO;
import com.jayrodharv.ngosmpwebappspringboot.dao.TagDAO;
import com.jayrodharv.ngosmpwebappspringboot.dto.build.BuildFormDTO;
import com.jayrodharv.ngosmpwebappspringboot.dto.build.BuildListDTO;
import com.jayrodharv.ngosmpwebappspringboot.dto.tag.NewTagDTO;
import com.jayrodharv.ngosmpwebappspringboot.dto.tag.TagDTO;
import com.jayrodharv.ngosmpwebappspringboot.pagination.PageRequest;
import com.jayrodharv.ngosmpwebappspringboot.pagination.PageResult;

import java.io.IOException;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@AllArgsConstructor
public class BuildService {

    private final BuildImageDAO buildImageDAO;
    private final BuildDAO buildDAO;
    private final TagDAO tagDAO;

    public PageResult<BuildListDTO> getBuilds(PageRequest request) {
        PageResult<BuildListDTO> builds = buildDAO.getBuilds(request);

        List<Integer> buildIds = builds
                .items()
                .stream()
                .map(BuildListDTO::buildId)
                .toList();

        Map<Integer, List<TagDTO>> tagsByBuild = tagDAO.getTagsForBuilds(buildIds);

        for (BuildListDTO build : builds.items()) {
            build
                .tags()
                .addAll(tagsByBuild.getOrDefault(tagsByBuild, List.of()));
        }

        return builds;
    }

    public Integer createBuild(CustomUserDetails actingUser, BuildFormDTO dto) {
        Set<Integer> finalTagIds = new HashSet<>(dto.tagIds());

        for (NewTagDTO tag : dto.newTags()) {
            Integer tagId = tagDAO.createOrGetTag(actingUser.getUserId(), tag);
            finalTagIds.add(tagId);
        }

        Integer buildId = buildDAO.createBuild(actingUser.getUserId(), dto);

        for (Integer tagId : finalTagIds) {
            buildDAO.addBuildTag(actingUser.getUserId(), buildId, tagId);
        }

        replaceImages(
            actingUser.getUserId(),
            buildId, dto.imageIds());

        return buildId;
    }

    public void replaceImages(Integer actingUserId, Integer buildId, List<Integer> imageIds) {

        buildImageDAO.deleteByBuildId(actingUserId, buildId);

        int sortOrder = 0;
        for (Integer imageId : imageIds) {
            buildImageDAO.create(
                    actingUserId,
                    buildId,
                    imageId,
                    sortOrder++);
        }
    }
}
