_Status_: Experimental.

Use *stubbs:migrate* to update your module to current
rerun module conventions.

Primarily, the migration support is responsible for 
the following:

* file naming conventions: Rename files to conform to the module file naming convention.
* file location and layout: Move files to expected locations inside the module.
* metadata properties: Rename or add required properties.
* public function names: Rename or add required rerun functions.
* metacomment headers: Ensure expected metacomments are present.

Excluded from the responsibility of `stubbs:migrate`:

* command implementations: Command script implementations will be left alone.
* module-specific functions: Any module-specific function scripts are ignored.
