@isTest
public class PF_NHW_LightningCompConfiguration_Test {

    private static testMethod void testLightningComponenetConfiguration() {
        String id = '12345678';
        String configFields = 'name;id';
        String dependencies = 'dep1';
        Set<String> dependencies_set = new Set<String>();
        dependencies_set.add(dependencies);
        PF_NHW_LightningComponentConfiguration lightningCmp = new PF_NHW_LightningComponentConfiguration(id, configFields);
        lightningCmp.addDependencies(dependencies_set);

        System.Assert(lightningCmp.fields.contains('name'));
        System.Assert(lightningCmp.fields.contains('id'));
        System.Assert(lightningCmp.dependencies.contains('dep1'));

    }
}