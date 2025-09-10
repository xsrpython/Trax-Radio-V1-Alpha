# 📚 Trax Radio UK - Documentation Index

## **Project Overview**
Trax Radio UK is a professional radio streaming app with automated versioning and release management.

---

## **📁 Documentation Structure**

### **Core Documentation**
- [`README.md`](README.md) - Main project overview
- [`DOCUMENTATION.md`](DOCUMENTATION.md) - This documentation index
- [`CHANGELOG.md`](CHANGELOG.md) - Version history and changes

### **Release Management**
- [`website/README.md`](website/README.md) - Website and release system
- [`website/RELEASE_STATUS.md`](website/RELEASE_STATUS.md) - Current release status
- [`website/CHANGELOG.md`](website/CHANGELOG.md) - Website version history

### **Technical Documentation**
- [`website/version-manager.ps1`](website/version-manager.ps1) - Version management script
- [`website/quick-release.bat`](website/quick-release.bat) - Quick release commands
- [`.github/workflows/`](.github/workflows/) - GitHub Actions workflows

---

## **🚀 Quick Reference**

### **Release Commands**
```bash
# Quick releases
quick-release.bat patch    # Bug fixes
quick-release.bat minor    # New features
quick-release.bat major    # Major updates

# Manual control
.\version-manager.ps1 -VersionType minor -Build -Release
```

### **Current Status**
- **Version**: 1.0.0+1
- **Status**: Released to Trax DJs and owners
- **Distribution**: Direct APK download via website

---

## **📋 File Organization**

### **Website Files** (`website/`)
- `index.html` - Main homepage
- `privacy-policy.html` - Privacy policy
- `styles.css` - CSS styles
- `script.js` - JavaScript functionality
- `releases/` - APK distribution folder

### **Release Management** (`website/`)
- `version-manager.ps1` - Advanced version control
- `quick-release.bat` - Simple release commands
- `CHANGELOG.md` - Version history
- `RELEASE_STATUS.md` - Current status tracking

### **GitHub Actions** (`.github/workflows/`)
- `build.yml` - Continuous integration
- `release.yml` - Automated releases

---

## **🔧 Development Workflow**

### **1. Collect Feedback**
- Gather input from Trax DJs and owners
- Document issues and feature requests

### **2. Plan Release**
- Determine version type (patch/minor/major)
- Update documentation as needed

### **3. Execute Release**
- Use automated release commands
- Monitor GitHub Actions for automation

### **4. Distribute**
- APK automatically uploaded to GitHub Releases
- Website updated with new download links
- Notify users of new version

---

## **📊 Version History**

| Version | Date | Type | Status |
|---------|------|------|--------|
| 1.0.0 | 2025-01-XX | Major | ✅ Released to DJs |

---

## **🆘 Support & Help**

### **For Developers**
- Check individual script files for detailed usage
- Review GitHub Actions workflows for automation
- Use version management tools for releases

### **For Users**
- Download APK from website releases folder
- Check release notes for new features
- Contact development team for issues

---

**Last Updated**: January 2025  
**Maintained By**: Trax Radio UK Development Team
