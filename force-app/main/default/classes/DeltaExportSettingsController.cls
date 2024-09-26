// Apex Class: DeltaExportSettingsController.cls
public with sharing class DeltaExportSettingsController {
    // Method to get current settings
    @AuraEnabled(cacheable=true)
    public static ExportSettings__c getSettings() {
        // Retrieve settings for the current user or org
        List<ExportSettings__c> settingsList = [SELECT Id, SelectedObjects__c, ExportFrequency__c, FileFormats__c, StorageOptions__c FROM ExportSettings__c LIMIT 1];
        if (!settingsList.isEmpty()) {
            return settingsList[0];
        } else {
            return null;
        }
    }

    // Method to save settings
    @AuraEnabled
    public static void saveSettings(String selectedObjects, String exportFrequency, String fileFormats, String storageOption) {
        ExportSettings__c settings;

        // Check if settings record already exists
        List<ExportSettings__c> existingSettings = [SELECT Id FROM ExportSettings__c LIMIT 1];
        if (!existingSettings.isEmpty()) {
            settings = existingSettings[0];
        } else {
            settings = new ExportSettings__c();
        }

        // Set the fields
        settings.SelectedObjects__c = selectedObjects;
        settings.ExportFrequency__c = exportFrequency;
        settings.FileFormats__c = fileFormats;
        settings.StorageOptions__c = storageOption;

        // Upsert settings (create or update)
        upsert settings;
    }
}
