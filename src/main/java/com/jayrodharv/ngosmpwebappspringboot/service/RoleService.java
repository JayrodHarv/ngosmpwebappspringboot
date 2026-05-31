package com.jayrodharv.ngosmpwebappspringboot.service;

import org.springframework.stereotype.Service;
import com.jayrodharv.ngosmpwebappspringboot.dao.RoleDAO;
import com.jayrodharv.ngosmpwebappspringboot.model.Role;

import java.util.List;
import java.util.Optional;

@Service
public class RoleService {

    private final RoleDAO roleDao;

    public RoleService(RoleDAO roleDao) { this.roleDao = roleDao; }

    public List<Role> findAll()               { return roleDao.findAll(); }
    public Optional<Role> findById(String id) { return roleDao.findById(id); }
    public void create(Role role)             { roleDao.insert(role); }
    public void update(Role role, String old) { roleDao.update(role, old); }
    public void delete(String roleId)         { roleDao.deleteById(roleId); }
}
