# 🌐 Trax Radio UK Website

## **Current Status: v1.0.0 Released** ✅

Trax Radio UK website with automated versioning and release management system.

---

## **Quick Start**

### **🚀 Release Commands**
```bash
# Quick patch release (1.0.0 → 1.0.1)
quick-release.bat patch

# Quick minor release (1.0.0 → 1.1.0)  
quick-release.bat minor

# Quick major release (1.0.0 → 2.0.0)
quick-release.bat major

# Just build APK
quick-release.bat build
```

### **📦 Manual Release**
```bash
# Full control over versioning
.\version-manager.ps1 -VersionType minor -Build -Release
```

---

## **File Structure**

```
website/
├── index.html              # Main homepage
├── privacy-policy.html     # Privacy policy page
├── styles.css             # CSS styles
├── script.js              # JavaScript functionality
├── quick-release.bat      # Quick release commands
├── version-manager.ps1    # Advanced version management
├── CHANGELOG.md           # Version history
├── RELEASE_STATUS.md      # Current release status
├── README.md              # This file
└── releases/              # APK files
    └── trax-radio-uk-v1.0.0.apk
```

---

## **Automated Features**

### **✅ Version Management**
- Automatic version bumping (patch/minor/major)
- Git tagging and commits
- Website version updates

### **✅ APK Building**
- Flutter APK building
- Automatic file copying
- Download link updates

### **✅ Release Management**
- GitHub release creation
- Release notes generation
- Automated website deployment

### **✅ GitHub Actions**
- Continuous integration
- Automated testing
- Release workflows

---

## **Current Release: v1.0.0+1**

**Status**: Released to Trax DJs and owners  
**Features**: Live streaming, DJ info, audio visualization  
**Distribution**: Direct APK download  

---

## **Next Steps**

1. **Collect feedback** from Trax DJs
2. **Use release commands** for updates
3. **Monitor GitHub Actions** for automation
4. **Update documentation** as needed

---

## **Support**

- **Documentation**: See individual files for detailed guides
- **Version Control**: Full Git integration with automated workflows
- **Releases**: Automated GitHub release management