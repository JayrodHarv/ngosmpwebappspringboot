package com.jayrodharv.ngosmpwebappspringboot.service;

import com.jayrodharv.ngosmpwebappspringboot.dao.BuildTypeDAO;
import com.jayrodharv.ngosmpwebappspringboot.model.BuildType;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class BuildTypeService {

    private final BuildTypeDAO buildTypeDAO;

    public BuildTypeService(BuildTypeDAO buildTypeDao) { this.buildTypeDAO = buildTypeDao; }

    public List<BuildType> findAll()               { return buildTypeDAO.findAll(); }
    public Optional<BuildType> findById(String id) { return buildTypeDAO.findById(id); }
    public void create(BuildType bt)               { buildTypeDAO.insert(bt); }
    public void update(BuildType bt, String oldId) { buildTypeDAO.update(bt, oldId); }
    public void delete(String id)                  { buildTypeDAO.deleteById(id); }
}
